# frozen_string_literal: true

require_relative 'util'

class Nanook
  # The <tt>Nanook::WalletAccount</tt> class lets you manage your nano accounts
  # that are on your node, including paying and receiving payment.
  #
  # === Initializing
  #
  # Initialize this class through an instance of {Nanook::Wallet} like this:
  #
  #   account = Nanook.new.wallet(wallet_id).account(account_id)
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   account = Nanook::WalletAccount.new(rpc_conn, wallet_id, account_id)
  class WalletAccount
    include Nanook::Util
    extend Forwardable
    # @!method ==
    #   (see Nanook::Account#==)
    # @!method balance(unit: Nanook.default_unit)
    #   (see Nanook::Account#balance)
    # @!method block_count
    #   (see Nanook::Account#block_count)
    # @!method delegators(unit: Nanook.default_unit)
    #   (see Nanook::Account#delegators)
    # @!method eql?
    #   (see Nanook::Account#eql?)
    # @!method exists?
    #   (see Nanook::Account#exists?)
    # @!method hash
    #   (see Nanook::Account#hash)
    # @!method history(limit: 1000, unit: Nanook.default_unit)
    #   (see Nanook::Account#history)
    # @!method id
    #   (see Nanook::Account#id)
    # @!method info((detailed: false, unit: Nanook.default_unit)
    #   (see Nanook::Account#info)
    # @!method last_modified_at
    #   (see Nanook::Account#last_modified_at)
    # @!method ledger(limit: 1, modified_since: nil, unit: Nanook.default_unit)
    #   (see Nanook::Account#ledger)
    # @!method pending(limit: 1000, detailed: false, unit: Nanook.default_unit)
    #   (see Nanook::Account#pending)
    # @!method public_key
    #   (see Nanook::Account#public_key)
    # @!method representative
    #   (see Nanook::Account#representative)
    # @!method weight
    #   (see Nanook::Account#weight)
    def_delegators :@nanook_account_instance,
                   :==, :balance, :block_count, :delegators, :eql?, :exists?, :hash, :history, :id,
                   :info, :last_modified_at, :ledger, :pending, :public_key, :representative, :weight
    alias open? exists?

    def initialize(rpc, wallet, account = nil)
      @rpc = rpc
      @wallet = wallet.to_s
      @account = account.to_s if account

      # Initialize an instance to delegate the RPC commands that do not
      # need `enable_control` enabled (the read-only RPC commands).
      @nanook_account_instance = nil

      return if @account.nil?

      # Wallet must contain the account
      unless Nanook::Wallet.new(@rpc, @wallet).contains?(@account)
        raise ArgumentError, "Account does not exist in wallet. Account: #{@account}, wallet: #{@wallet}"
      end

      @nanook_account_instance = as_account(@account)
    end

    # @param account [Nanook::WalletAccount] wallaccountet to compare
    # @return [Boolean] true if accounts are equal
    def ==(other)
      other.class == self.class &&
        other.id == @account
    end
    alias eql? ==

    # The hash value is used along with #eql? by the Hash class to determine if two objects
    # reference the same hash key.
    #
    # @return [Integer]
    def hash
      [@wallet, @account].join('+').hash
    end

    # Creates a new account, or multiple new accounts, in this wallet.
    #
    # ==== Examples:
    #
    #   wallet.create     # => Nanook::WalletAccount
    #   wallet.create(2)  # => [Nanook::WalletAccount, Nanook::WalletAccount]
    #
    # @param n_accounts [Integer] number of accounts to create
    #
    # @return [Nanook::WalletAccount] returns a single {Nanook::WalletAccount}
    #   if invoked with no argument
    # @return [Array<Nanook::WalletAccount>] returns an Array of {Nanook::WalletAccount}
    #   if method was called with argument +n+ >  1
    # @raise [ArgumentError] if +n+ is less than 1
    def create(n_accounts = 1)
      skip_account_required!
      raise ArgumentError, 'number of accounts must be greater than 0' if n_accounts < 1

      if n_accounts == 1
        as_wallet_account(rpc(:account_create, _access: :account))
      else
        rpc(:accounts_create, count: n_accounts, _access: :accounts, _coerce: Array).map do |account|
          as_wallet_account(account)
        end
      end
    end

    # Unlinks the account from the wallet.
    #
    # ==== Example:
    #
    #   account.destroy # => true
    #
    # @return [Boolean] +true+ if action was successful, otherwise +false+
    def destroy
      rpc(:account_remove, _access: :removed) == 1
    end

    # @return [String]
    def to_s
      "#{self.class.name}(id: \"#{short_id}\")"
    end
    alias inspect to_s

    # Makes a payment from this account to another account
    # on the nano network. Returns a <i>send</i> block hash
    # if successful, or a {Nanook::NodeRpcError} if unsuccessful.
    #
    # Note, there may be a delay in receiving a response due to Proof
    # of Work being done. From the {Nano RPC}[https://docs.nano.org/commands/rpc-protocol/#send]:
    #
    # <i>Proof of Work is precomputed for one transaction in the background. If it has been a while since your last transaction it will send instantly, the next one will need to wait for Proof of Work to be generated.</i>
    #
    # ==== Examples:
    #
    #   account.pay(to: "nano_...", amount: 1.1, id: "myUniqueId123") # => "9AE2311..."
    #   account.pay(to: "nano_...", amount: 54000000000000, id: "myUniqueId123", unit: :raw) # => "9AE2311..."
    #
    # @param to [String] account id of the recipient of your payment
    # @param amount [Integer|Float]
    # @param unit (see Nanook::Account#balance)
    # @param id [String] must be unique per payment. It serves an important
    #   purpose; it allows you to make the same call multiple times with
    #   the same +id+ and be reassured that you will only ever send this
    #   nano payment once
    # @return [Nanook::Block] the send block for the payment
    # @raise [Nanook::NodeRpcError] if unsuccessful
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def pay(to:, amount:, id:, unit: Nanook.default_unit)
      validate_unit!(unit)

      # Check that to account is a valid address
      valid = @rpc.call(:validate_account_number, account: to, _access: :valid) == 1
      raise ArgumentError, "Account address is invalid: #{to}" unless valid

      # Determine amount in raw
      raw = if unit.to_sym.eql?(:nano)
              NANO_to_raw(amount)
            else
              amount
            end

      # account is called source, so don't use the normal rpc method
      params = {
        wallet: @wallet,
        source: @account,
        destination: to,
        amount: raw,
        id: id,
        _access: :block
      }

      as_block(@rpc.call(:send, params))
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
    #   account.receive               # => Nanook::Block
    #   account.receive("718CC21...") # => Nanook::Block
    #
    # @param block [String] optional block id of pending payment. If
    #   not provided, the latest pending payment will be received
    # @return [Nanook::Block] the receive block
    # @return [false] if there was no block to receive
    def receive(block = nil)
      return receive_without_block if block.nil?

      receive_with_block(block)
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
    # Also see {Nanook::Wallet#change_default_representative} for how to set a default
    # representative for all new accounts created in a wallet.
    #
    # ==== Example:
    #
    #   account.change_representative("nano_...") # => Nanook::Block
    #
    # @param representative [String] the id of the representative account
    #   to set as this account's representative
    # @return [Nanook::Block] <i>change</i> block created
    # @raise [Nanook::Error] if setting the representative account fails
    def change_representative(representative)
      unless as_account(representative).exists?
        raise Nanook::Error, "Representative account does not exist: #{representative}"
      end

      block = rpc(:account_representative_set, representative: representative, _access: :block)
      as_block(block)
    end

    # Returns the work for the account.
    #
    # ==== Example:
    #
    #   account.work # => "432e5cf728c90f4f"
    #
    # @return [String] work
    def work
      rpc(:work_get, _access: :work)
    end

    # Set work for account.
    #
    # ==== Example:
    #
    #   account.set_work("432e5cf728c90f4f") # => true
    #
    # @return [Boolean] true if action was successful
    def set_work(work)
      rpc(:work_set, work: work).key?(:success)
    end

    private

    def receive_without_block
      # Discover the first pending block
      pending_blocks = @rpc.call(:pending, { account: @account, count: 1, _access: :blocks, _coerce: Array })

      return false if pending_blocks.empty?

      # Then call receive_with_block as normal
      block = pending_blocks[0]
      receive_with_block(block)
    end

    # Returns block if successful, otherwise false
    def receive_with_block(block)
      response = rpc(:receive, block: block, _access: :block)
      response ? as_block(response) : false
    end

    def rpc(action, params = {})
      check_account_required!

      p = { wallet: @wallet, account: @account }.compact
      @rpc.call(action, p.merge(params)).tap { reset_skip_account_required! }
    end

    def skip_account_required!
      @skip_account_required_check = true
    end

    def reset_skip_account_required!
      @skip_account_required_check = false
    end

    def check_account_required!
      return if @account || @skip_account_required_check

      raise ArgumentError, 'Account must be present'
    end
  end
end
