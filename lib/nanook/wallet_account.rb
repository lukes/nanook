class Nanook
  class WalletAccount

    extend Forwardable
    # @!method balance(unit: Nanook.default_unit)
    #   (see Nanook::Account#balance)
    # @!method delegators
    #   (see Nanook::Account#delegators)
    # @!method exists?
    #   (see Nanook::Account#exists?)
    # @!method history(limit: 1000, unit: Nanook.default_unit)
    #   (see Nanook::Account#history)
    # @!method id
    #   (see Nanook::Account#id)
    # @!method info((detailed: false, unit: Nanook.default_unit)
    #   (see Nanook::Account#info)
    # @!method last_modified_at
    #   (see Nanook::Account#last_modified_at)
    # @!method ledger(limit: 1)
    #   (see Nanook::Account#ledger)
    # @!method pending(limit: 1000, detailed: false, unit: Nanook.default_unit)
    #   (see Nanook::Account#pending)
    # @!method public_key
    #   (see Nanook::Account#public_key)
    # @!method representative
    #   (see Nanook::Account#representative)
    # @!method weight
    #   (see Nanook::Account#weight)
    def_delegators :@nanook_account_instance, :balance, :delegators, :exists?, :history, :id, :info, :last_modified_at, :ledger, :pending, :public_key, :representative, :weight
    alias_method :open?, :exists?

    def initialize(rpc, wallet, account)
      @rpc = rpc
      @wallet = wallet
      @account = account
      @nanook_account_instance = nil

      unless @account.nil?
        # Wallet must contain the account
        unless Nanook::Wallet.new(@rpc, @wallet).contains?(@account)
          raise ArgumentError.new("Account does not exist in wallet. Account: #{@account}, wallet: #{@wallet}")
        end

        # An object to delegate account methods that don't
        # expect a wallet param in the RPC call, to allow this
        # class to support all methods that can be called on Nanook::Account
        @nanook_account_instance = Nanook::Account.new(@rpc, @account)
      end
    end

    # Creates a new account, or multiple new accounts, in this wallet.
    #
    # ==== Examples:
    #
    #   wallet.create     # => Nanook::WalletAccount
    #   wallet.create(2)  # => [Nanook::WalletAccount, Nanook::WalletAccount]
    #
    # @param n [Integer] number of accounts to create
    #
    # @return [Nanook::WalletAccount] returns a single {Nanook::WalletAccount}
    #   if invoked with no argument
    # @return [Array<Nanook::WalletAccount>] returns an Array of {Nanook::WalletAccount}
    #   if method was called with argument +n+ >  1
    def create(n=1)
      if n < 1
        raise ArgumentError.new("number of accounts must be greater than 0")
      end

      if n == 1
        Nanook::WalletAccount.new(@rpc, @wallet, rpc(:account_create)[:account])
      else
        Array(rpc(:accounts_create, count: n)[:accounts]).map do |account|
          Nanook::WalletAccount.new(@rpc, @wallet, account)
        end
      end
    end

    # Unlinks the account from the wallet.
    #
    # ==== Example:
    #
    #   account.destroy # => true
    #
    # @return [Boolean] true if action was successful, otherwise +false+
    def destroy
      rpc(:account_remove)[:removed] == 1
    end

    # @return [String]
    def inspect
      "#{self.class.name}(wallet_id: #{@wallet}, account_id: #{id}, object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    # Make a payment from an account in this wallet to another account
    # on the nano network. Returns a <i>send</i> block hash
    # if successful, or a {Nanook::Error} if unsuccessful.
    #
    # Note, there may be a delay in receiving a response due to Proof
    # of Work being done. From the {Nano RPC}[https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol#account-create]:
    #
    # <i>Proof of Work is precomputed for one transaction in the background. If it has been a while since your last transaction it will send instantly, the next one will need to wait for Proof of Work to be generated.</i>
    #
    # ==== Examples:
    #
    #   account.pay(to: "xrb_...", amount: 1.1, id: "myUniqueId123") # => "9AE2311..."
    #   account.pay(to: "xrb_...", amount: 54000000000000, id: "myUniqueId123", unit: :raw) # => "9AE2311..."
    #
    # @param to [String] account id of the recipient of your payment
    # @param amount [Integer|Float]
    # @param unit (see Nanook::Account#balance)
    # @param id [String] must be unique per payment. It serves an important
    #   purpose; it allows you to make the same call multiple times with
    #   the same +id+ and be reassured that you will only ever send this
    #   nano payment once
    # @return [String] the send block id for the payment
    # @raise [Nanook::Error] if unsuccessful
    def pay(to:, amount:, unit: Nanook::default_unit, id:)
      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      # Check that to account is a valid address
      response = @rpc.call(:validate_account_number, account: to)
      unless response[:valid] == 1
        raise ArgumentError.new("Account address is invalid: #{to}")
      end

      # Determin amount in raw
      raw = if unit.to_sym.eql?(:nano)
        Nanook::Util.NANO_to_raw(amount)
      else
        amount
      end

      # account is called source, so don't use the normal rpc method
      p = {
        wallet: @wallet,
        source: @account,
        destination: to,
        amount: raw,
        id: id
      }

      response = @rpc.call(:send, p)

      if response.has_key?(:error)
        return Nanook::Error.new(response[:error])
      end

      response[:block]
    end

    # Receives a pending payment for this account.
    #
    # When called with no +block+ argument, the latest pending payment
    # for the account will be received.
    #
    # Returns a <i>receive</i> block id
    # if a receive was successful, or +false+ if there were no pending
    # payments to receive.
    #
    # You can receive a specific pending block if you know it by
    # passing the block in as an argument.
    #
    # ==== Examples:
    #
    #   account.receive               # => "9AE2311..."
    #   account.receive("718CC21...") # => "9AE2311..."
    #
    # @param block [String] optional block id of pending payment. If
    #   not provided, the latest pending payment will be received
    # @return [String] the receive block id
    # @return [false] if there was no block to receive
    def receive(block=nil)
      if block.nil?
        _receive_without_block
      else
        _receive_with_block(block)
      end
    end

    # Sets the representative for the account.
    #
    # A representative is an account that will vote on your account's
    # behalf on the nano network if your account is offline and there is
    # a fork of the network that requires voting on.
    #
    # Returns the <em>change block</em> that was
    # broadcast to the nano network. The block contains the information
    # about the representative change for your account.
    #
    # ==== Example:
    #
    #   account.change_representative("xrb_...") # => "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"
    #
    # @param [String] representative the id of the representative account
    #   to set as this account's representative
    # @return [String] id of the <i>change</i> block created
    # @raise [ArgumentError] if the representative account does not exist
    def change_representative(representative)
      unless Nanook::Account.new(@rpc, representative).exists?
        raise ArgumentError.new("Representative account does not exist: #{representative}")
      end

      rpc(:account_representative_set, representative: representative)[:block]
    end

    private

    def _receive_without_block
      # Discover the first pending block
      pending_blocks = @rpc.call(:pending, { account: @account, count: 1 })

      if pending_blocks[:blocks].empty?
        return false
      end

      # Then call receive_with_block as normal
      block = pending_blocks[:blocks][0]
      _receive_with_block(block)
    end

    # Returns block if successful, otherwise false
    def _receive_with_block(block)
      response = rpc(:receive, block: block)[:block]
      response.nil? ? false : response
    end

    def rpc(action, params={})
      p = {}
      p[:wallet] = @wallet unless @wallet.nil?
      p[:account] = @account unless @account.nil?

      @rpc.call(action, p.merge(params))
    end

  end
end
