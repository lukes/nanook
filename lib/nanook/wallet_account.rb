class Nanook
  class WalletAccount

    UNITS = [:raw, :nano]
    DEFAULT_UNIT = :nano

    def initialize(rpc, wallet, account)
      @rpc = rpc
      @wallet = wallet
      @account = account

      # An object to delegate account methods that don't
      # expect a wallet param in the RPC call, to allow this
      # class to support all methods that can be called on Nanook::Account
      @nanook_account_instance = Nanook::Account.new(@rpc, @account)

      # Wallet instance to call contains? on to check account
      # is in wallet
      @nanook_wallet_instance = Nanook::Wallet.new(@rpc, @wallet)

      if @account
        account_must_belong_to_wallet!
      end
    end

    def account_id
      @account
    end

    def create(n=1)
      if n < 1
        raise ArgumentError.new("number of accounts must be greater than 1")
      end

      wallet_required!

      if n == 1
        rpc(:account_create)[:account]
      else
        rpc(:accounts_create, count: n)[:accounts]
      end
    end

    def destroy
      wallet_required!
      (rpc(:account_remove)[:removed] == 1).tap do |success|
        @known_valid_accounts.delete(@account) if success
      end
    end

    def inspect # :nodoc:
      "#{self.class.name}(wallet_id: #{wallet_id}, account_id: #{account_id}, object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    def pay(to:, amount:, unit: DEFAULT_UNIT, id:)
      wallet_required!

      unless UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      # Check that to: account is valid
      unless Nanook::Account.new(@rpc, to).exists?
        raise ArgumentError.new("To account does not exist (#{to})")
      end

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
        return response[:error]
      end

      response[:block]
    end

    # Returns false if no block to receive
    def receive(block=nil)
      wallet_required!

      if block.nil?
        _receive_without_block
      else
        _receive_with_block(block)
      end
    end

    def wallet_id
      @wallet
    end

    # Any method of Nanook::Account can be called on this class too
    def method_missing(m, *args, &block)
      if @nanook_account_instance.respond_to?(m)
        @nanook_account_instance.send(m, *args, &block)
      else
        super(m, *args, &block)
      end
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

    def wallet_required!
      if @wallet.nil?
        raise ArgumentError.new("Wallet must be present")
      end
    end

    def account_must_belong_to_wallet!
      if @account.nil?
        raise ArgumentError.new("Account must be present")
      end

      @known_valid_accounts ||= []

      # validate account is in wallet
      return if @known_valid_accounts.include?(@account)

      if @nanook_wallet_instance.contains?(@account)
        @known_valid_accounts << @account
      else
        raise ArgumentError.new("Account does not exist in wallet. Account: #{@account}, wallet: #{@wallet}")
      end
    end

  end
end
