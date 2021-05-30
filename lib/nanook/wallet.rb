# frozen_string_literal: true

require_relative 'util'

class Nanook
  # The <tt>Nanook::Wallet</tt> class lets you manage your nano wallets.
  # Your node will need the <tt>enable_control</tt> setting enabled.
  #
  # === Wallet seeds vs ids
  #
  # Your wallets each have an id as well as a seed. Both are 32-byte uppercase hex
  # strings that look like this:
  #
  #   000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F
  #
  # This class uses wallet _ids_ to identify your wallet. A wallet id only
  # exists locally on the nano node that it was created on. The person
  # who knows this id can only perform all read and write actions against
  # the wallet and all accounts inside the wallet from the same nano node
  # that it was created on. This makes wallet ids fairly safe to use as a
  # person needs to know your wallet id as well as have access to run
  # RPC commands against your nano node to be able to control your accounts.
  #
  # A _seed_ on the other hand can be used to link any wallet to another
  # wallet's accounts, from anywhere in the nano network. This happens
  # by setting a wallet's seed to be the same as a previous wallet's seed.
  # When a wallet has the same seed as another wallet, any accounts
  # created in the second wallet will be the same accounts as those that were
  # created in the previous wallet, and the new wallet's owner will
  # also gain ownership of the previous wallet's accounts. Note, that the
  # two wallets will have different ids, but the same seed.
  #
  # Nanook is based on the Nano RPC, which uses wallet ids and not seeds.
  # The RPC and therefore Nanook cannot tell you what a wallet's seed is,
  # only its id. Knowing a wallet's seed is very useful for if you ever
  # want to restore the wallet anywhere else on the nano network besides
  # the node you originally created it on. The nano command line interface
  # (CLI) is the only method for discovering a wallet's seed. See the
  # {https://docs.nano.org/commands/command-line-interface/#-wallet_decrypt_unsafe-walletwallet-passwordpassword}.
  #
  # === Initializing
  #
  # Initialize this class through the convenient {Nanook#wallet} method:
  #
  #   nanook = Nanook.new
  #   wallet = nanook.wallet(wallet_id)
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   wallet = Nanook::Wallet.new(rpc_conn, wallet_id)
  class Wallet
    include Nanook::Util

    def initialize(rpc, wallet = nil)
      @rpc = rpc
      @wallet = wallet.to_s if wallet
    end

    # @return [String] the wallet id
    def id
      @wallet
    end

    # @param other [Nanook::Wallet] wallet to compare
    # @return [Boolean] true if wallets are equal
    def ==(other)
      other.class == self.class &&
        other.id == id
    end
    alias eql? ==

    # The hash value is used along with #eql? by the Hash class to determine if two objects
    # reference the same hash key.
    #
    # @return [Integer]
    def hash
      id.hash
    end

    # Returns the given account in the wallet as a {Nanook::WalletAccount} instance
    # to let you start working with it.
    #
    # Call with no +account+ argument if you wish to create a new account
    # in the wallet, like this:
    #
    #   wallet.account.create     # => Nanook::WalletAccount
    #
    # See {Nanook::WalletAccount} for all the methods you can call on the
    # account object returned.
    #
    # ==== Examples:
    #
    #   wallet.account("nano_...") # => Nanook::WalletAccount
    #   wallet.account.create     # => Nanook::WalletAccount
    #
    # @param account [String] optional String of an account (starting with
    #   <tt>"xrb..."</tt>) to start working with. Must be an account within
    #   the wallet. When no account is given, the instance returned only
    #   allows you to call +create+ on it, to create a new account.
    # @raise [ArgumentError] if the wallet does not contain the account
    # @return [Nanook::WalletAccount]
    def account(account = nil)
      check_wallet_required!

      # We `allow_blank` in order to support `WalletAccount#create`.
      as_wallet_account(account, allow_blank: true)
    end

    # Array of {Nanook::WalletAccount} instances of accounts in the wallet.
    #
    # See {Nanook::WalletAccount} for all the methods you can call on the
    # account objects returned.
    #
    # ==== Example:
    #
    #   wallet.accounts # => [Nanook::WalletAccount, Nanook::WalletAccount...]
    #
    # @return [Array<Nanook::WalletAccount>] all accounts in the wallet
    def accounts
      rpc(:account_list, _access: :accounts, _coerce: Array).map do |account|
        as_wallet_account(account)
      end
    end

    # Move accounts from another {Nanook::Wallet} on the node to this {Nanook::Wallet}.
    #
    # ==== Example:
    #
    #   wallet.move_accounts("0023200...", ["nano_3e3j5...", "nano_5f2a1..."]) # => true
    #
    # @return [Boolean] true when the move was successful
    def move_accounts(wallet, accounts)
      rpc(:account_move, source: wallet, accounts: accounts, _access: :moved) == 1
    end

    # Remove an {Nanook::Account} from this {Nanook::Wallet}.
    #
    # ==== Example:
    #
    #   wallet.remove_account("nano_3e3j5...") # => true
    #
    # @return [Boolean] true when the remove was successful
    def remove_account(account)
      rpc(:account_remove, account: account, _access: :removed) == 1
    end

    # Balance of all accounts in the wallet, optionally breaking the balances down by account.
    #
    # ==== Examples:
    #   wallet.balance
    #
    # Example response:
    #
    #   {
    #     "balance"=>5,
    #     "pending"=>0.001
    #   }
    #
    # Asking for the balances to be returned in raw instead of NANO.
    #
    #   wallet.balance(unit: :raw)
    #
    # Example response:
    #
    #   {
    #     "balance"=>5000000000000000000000000000000,
    #     "pending"=>1000000000000000000000000000
    #   }
    #
    # Asking for totals to be broken down by account:
    #
    #   wallet.balance(account_break_down: true)
    #
    # Example response:
    #
    #   {
    #     "nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"=>{
    #       "balance"=>2.5,
    #       "pending"=>1
    #     },
    #     "nano_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3sxwjym5rx"=>{
    #       "balance"=>51.4,
    #       "pending"=>0
    #     },
    #   }
    #
    # @param account_break_down [Boolean] (default is +false+). When +true+
    #  the response will contain balances per account.
    # @param unit (see Nanook::Account#balance)
    #
    # @return [Hash{Symbol=>Integer|Float|Hash}]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def balance(account_break_down: false, unit: Nanook.default_unit)
      validate_unit!(unit)

      if account_break_down
        return rpc(:wallet_balances, _access: :balances, _coerce: Hash).tap do |r|
          if unit == :nano
            r.each do |account, _balances|
              r[account][:balance] = raw_to_NANO(r[account][:balance])
              r[account][:pending] = raw_to_NANO(r[account][:pending])
            end
          end
        end
      end

      response = rpc(:wallet_info, _coerce: Hash).slice(:balance, :pending)
      return response unless unit == :nano

      {
        balance: raw_to_NANO(response[:balance]),
        pending: raw_to_NANO(response[:pending])
      }
    end

    # Changes a wallet's seed.
    #
    # It's recommended to only change the seed of a wallet that contains
    # no accounts. This will clear all deterministic accounts in the wallet.
    # To restore accounts after changing the seed, see Nanook::WalletAccount#create.
    #
    # ==== Example:
    #
    #   wallet.change_seed("000D1BA...") # => true
    #   wallet.account.create(5) # Restores first 5 accounts for wallet with new seed
    #
    # @param seed [String] the seed to change to.
    # @return [Boolean] indicating whether the change was successful.
    def change_seed(seed)
      rpc(:wallet_change_seed, seed: seed).key?(:success)
    end

    # Creates a new wallet.
    #
    # The wallet will be created only on this node. It's important that
    # if you intend to add funds to accounts in this wallet that you
    # backup the wallet *seed* in order to restore the wallet in future.
    # The nano command line interface (CLI) is the only method for
    # backing up a wallet's seed. See the
    # {https://github.com/nanocurrency/raiblocks/wiki/Command-line-interface
    # --wallet_decrypt_unsafe CLI command}.
    #
    # ==== Example:
    #   Nanook.new.wallet.create # => Nanook::Wallet
    #
    # @return [Nanook::Wallet]
    def create
      skip_wallet_required!
      @wallet = rpc(:wallet_create, _access: :wallet)
      self
    end

    # Destroys the wallet.
    #
    # ==== Example:
    #
    #   wallet.destroy # => true
    #
    # @return [Boolean] indicating success of the action
    def destroy
      rpc(:wallet_destroy, _access: :destroyed) == 1
    end

    # Generates a String containing a JSON representation of your wallet.
    #
    # ==== Example:
    #
    #   wallet.export
    #     # => "{\n    \"0000000000000000000000000000000000000000000000000000000000000000\": \"0000000000000000000000000000000000000000000000000000000000000003\",\n    \"0000000000000000000000000000000000000000000000000000000000000001\": \"C3A176FC3B90113277BFC91F55128FC9A1F1B6166A73E7446927CFFCA4C2C9D9\",\n    \"0000000000000000000000000000000000000000000000000000000000000002\": \"3E58EC805B99C52B4715598BD332C234A1FBF1780577137E18F53B9B7F85F04B\",\n    \"0000000000000000000000000000000000000000000000000000000000000003\": \"5FF8021122F3DEE0E4EC4241D35A3F41DEF63CCF6ADA66AF235DE857718498CD\",\n    \"0000000000000000000000000000000000000000000000000000000000000004\": \"A30E0A32ED41C8607AA9212843392E853FCBCB4E7CB194E35C94F07F91DE59EF\",\n    \"0000000000000000000000000000000000000000000000000000000000000005\": \"E707002E84143AA5F030A6DB8DD0C0480F2FFA75AB1FFD657EC22B5AA8E395D5\",\n    \"0000000000000000000000000000000000000000000000000000000000000006\": \"0000000000000000000000000000000000000000000000000000000000000001\",\n    \"8646C0423160DEAEAA64034F9C6858F7A5C8A329E73E825A5B16814F6CCAFFE3\": \"0000000000000000000000000000000000000000000000000000000100000000\"\n}\n"
    #
    # @return [String]
    def export
      rpc(:wallet_export, _access: :json)
    end

    # Returns true if wallet exists on the node.
    #
    # ==== Example:
    #
    #   wallet.exists? # => true
    #
    # @return [Boolean] true if wallet exists on the node
    def exists?
      export
      true
    rescue Nanook::NodeRpcError
      false
    end

    # Will return +true+ if the account exists in the wallet.
    #
    # ==== Example:
    #   wallet.contains?("nano_...") # => true
    #
    # @param account [String] id (will start with <tt>"nano_..."</tt>)
    # @return [Boolean] indicating if the wallet contains the given account
    def contains?(account)
      rpc(:wallet_contains, account: account, _access: :exists) == 1
    end

    # @return [String]
    def to_s
      "#{self.class.name}(id: \"#{short_id}\")"
    end
    alias inspect to_s

    # Makes a payment from an account in your wallet to another account
    # on the nano network.
    #
    # Note, there may be a delay in receiving a response due to Proof of
    # Work being done. From the {Nano RPC}[https://docs.nano.org/commands/rpc-protocol/#send]:
    #
    # <i>Proof of Work is precomputed for one transaction in the
    # background. If it has been a while since your last transaction it
    # will send instantly, the next one will need to wait for Proof of
    # Work to be generated.</i>
    #
    # ==== Examples:
    #
    #   wallet.pay(from: "nano_...", to: "nano_...", amount: 1.1, id: "myUniqueId123") # => "9AE2311..."
    #   wallet.pay(from: "nano_...", to: "nano_...", amount: 54000000000000, unit: :raw, id: "myUniqueId123")
    #     # => "9AE2311..."
    #
    # @param from [String] account id of an account in your wallet
    # @param to (see Nanook::WalletAccount#pay)
    # @param amount (see Nanook::WalletAccount#pay)
    # @param unit (see Nanook::Account#balance)
    # @params id (see Nanook::WalletAccount#pay)
    # @return (see Nanook::WalletAccount#pay)
    # @raise [Nanook::Error] if unsuccessful
    def pay(from:, to:, amount:, id:, unit: Nanook.default_unit)
      validate_wallet_contains_account!(from)
      account(from).pay(to: to, amount: amount, unit: unit, id: id)
    end

    # Information about pending blocks (payments) that are waiting
    # to be received by accounts in this wallet.
    #
    # See also the {#receive} method of this class for how to receive a pending payment.
    #
    # @param limit [Integer] number of accounts with pending payments to return (default is 1000)
    # @param allow_unconfirmed [Boolean] +false+ by default. When +false+ only returns block which
    #   have their confirmation height set or are undergoing confirmation height processing.
    # @param detailed [Boolean]return a more complex Hash of pending block information (default is +false+)
    # @param unit (see Nanook::Account#balance)
    #
    # ==== Examples:
    #
    #   wallet.pending
    #
    # Example response:
    #
    #   {
    #     Nanook::Account=>[
    #       Nanook::Block,
    #       Nanook::Block"
    #     ],
    #     Nanook::Account=>[
    #       Nanook::Block
    #     ]
    #   }
    #
    # Asking for more information:
    #
    #   wallet.pending(detailed: true)
    #
    # Example response:
    #
    #   {
    #     Nanook::Account=>[
    #       {
    #         :amount=>6.0,
    #         :source=>Nanook::Account,
    #         :block=>Nanook::Block
    #       },
    #       {
    #         :amount=>12.0,
    #         :source=>Nanook::Account,
    #         :block=>Nanook::Block
    #       }
    #     ],
    #     Nanook::Account=>[
    #       {
    #         :amount=>106.370018,
    #         :source=>Nanook::Account,
    #         :block=>Nanook::Block
    #       }
    #     ]
    #   }
    #
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def pending(limit: 1000, detailed: false, allow_unconfirmed: false, unit: Nanook.default_unit)
      validate_unit!(unit)

      params = {
        count: limit,
        include_only_confirmed: !allow_unconfirmed,
        _access: :blocks,
        _coerce: Hash
      }

      params[:source] = true if detailed

      response = rpc(:wallet_pending, params)

      unless detailed

        x = response.map do |account, block_ids|
          blocks = block_ids.map { |block_id| as_block(block_id) }
          [as_account(account), blocks]
        end

        return Hash[x]
      end

      # Map the RPC response, which is:
      # account=>block=>[amount|source] into
      # account=>[block|amount|source]
      x = response.map do |account, data|
        new_data = data.map do |block, amount_and_source|
          d = {
            block: as_block(block),
            source: as_account(amount_and_source[:source]),
            amount: amount_and_source[:amount]
          }
          d[:amount] = raw_to_NANO(d[:amount]) if unit == :nano
          d
        end

        [as_account(account), new_data]
      end

      Hash[x]
    end

    # Receives a pending payment into an account in the wallet.
    #
    # When called with no +block+ argument, the latest pending payment
    # for the account will be received.
    #
    # Returns a <i>receive</i> block if a receive was successful,
    # or +false+ if there were no pending payments to receive.
    #
    # You can receive a specific pending block if you know it by
    # passing the block has in as an argument.
    #
    # ==== Examples:
    #
    #   wallet.receive(into: "xrb...")               # => Nanook::Block
    #   wallet.receive("718CC21...", into: "xrb...") # => Nanook::Block
    #
    # @param block (see Nanook::WalletAccount#receive)
    # @param into [String] account id of account in your wallet to receive the
    #   payment into
    # @return (see Nanook::WalletAccount#receive)
    def receive(block = nil, into:)
      validate_wallet_contains_account!(into)
      account(into).receive(block)
    end

    # Rebroadcast blocks for accounts from wallet starting at frontier down to count to the network.
    #
    # ==== Examples:
    #
    #   wallet.republish_blocks             # => [Nanook::Block, ...]
    #   wallet.republish_blocks(limit: 10)  # => [Nanook::Block, ...
    #
    # @param limit [Integer] limit of blocks to publish. Default is 1000.
    # @return [Array<Nanook::Block>] republished blocks
    def republish_blocks(limit: 1000)
      rpc(:wallet_republish, count: limit, _access: :blocks, _coerce: Array).map do |block|
        as_block(block)
      end
    end

    # The default representative account id for the wallet. This is the
    # representative that all new accounts created in this wallet will have.
    #
    # Changing the default representative for a wallet does not change
    # the representatives for any accounts that have been created.
    #
    # ==== Example:
    #
    #   wallet.default_representative # => "nano_3pc..."
    #
    # @return [Nanook::Account] Representative account. Can be nil.
    def default_representative
      representative = rpc(:wallet_representative, _access: :representative)
      as_account(representative)
    end
    alias representative default_representative

    # Sets the default representative for the wallet. A wallet's default
    # representative is the representative all new accounts created in
    # the wallet will have. Changing the default representative for a
    # wallet does not change the representatives for existing accounts
    # in the wallet.
    #
    # ==== Example:
    #
    #   wallet.change_default_representative("nano_...") # => "nano_..."
    #
    # @param representative [String] id of the representative account
    #   to set as this account's representative
    # @return [Nanook::Account] the representative account
    # @raise [Nanook::Error] if setting the representative fails
    def change_default_representative(representative)
      unless as_account(representative).exists?
        raise Nanook::Error, "Representative account does not exist: #{representative}"
      end

      raise Nanook::Error, 'Setting the representative failed' \
        unless rpc(:wallet_representative_set, representative: representative, _access: :set) == 1

      as_account(representative)
    end
    alias change_representative change_default_representative

    # Restores a previously created wallet by its seed.
    # A new wallet will be created on your node (with a new wallet id)
    # and will have its seed set to the given seed.
    #
    # ==== Example:
    #
    #   Nanook.new.wallet.restore(seed) # => Nanook::Wallet
    #
    # @param seed [String] the wallet seed to restore.
    # @param accounts [Integer] optionally restore the given number of accounts for the wallet.
    #
    # @return [Nanook::Wallet] a new wallet
    # @raise [Nanook::Error] if unsuccessful
    def restore(seed, accounts: 0)
      skip_wallet_required!

      create

      raise Nanook::Error, 'Unable to set seed for wallet' unless change_seed(seed)

      account.create(accounts) if accounts.positive?

      self
    end

    # Information ledger information about this wallet's accounts.
    #
    # This call may return results that include unconfirmed blocks, so it should not be
    # used in any processes or integrations requiring only details from blocks confirmed
    # by the network.
    #
    # ==== Examples:
    #
    #   wallet.ledger
    #
    # Example response:
    #
    #    {
    #      Nanook::Account => {
    #        frontier: "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
    #        open_block: "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
    #        representative_block: "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
    #        balance: 1.45,
    #        modified_timestamp: 1511476234,
    #        block_count: 2
    #      },
    #      Nanook::Account => { ... }
    #    }
    #
    # @param unit (see Nanook::Account#balance)
    # @return [Hash{Nanook::Account=>Hash{Symbol=>Nanook::Block|Integer|Float|Time}}] ledger.
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def ledger(unit: Nanook.default_unit)
      validate_unit!(unit)

      response = rpc(:wallet_ledger, _access: :accounts, _coerce: Hash)

      accounts = response.map do |account_id, data|
        data[:frontier] = as_block(data[:frontier])
        data[:open_block] = as_block(data[:open_block])
        data[:representative_block] = as_block(data[:representative_block])
        data[:balance] = raw_to_NANO(data[:balance]) if unit == :nano
        data[:last_modified_at] = as_time(data.delete(:modified_timestamp))

        [as_account(account_id), data]
      end

      Hash[accounts]
    end

    # Information about this wallet.
    #
    # This call may return results that include unconfirmed blocks, so it should not be
    # used in any processes or integrations requiring only details from blocks confirmed
    # by the network.
    #
    # ==== Examples:
    #
    #   wallet.info
    #
    # Example response:
    #
    #   {
    #     balance: 1.0,
    #     pending: 2.3
    #     accounts_count: 3,
    #     adhoc_count: 1,
    #     deterministic_count: 2,
    #     deterministic_index: 2
    # }
    #
    # @param unit (see Nanook::Account#balance)
    # @return [Hash{Symbol=>Integer|Float}] information about the wallet.
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def info(unit: Nanook.default_unit)
      validate_unit!(unit)

      response = rpc(:wallet_info, _coerce: Hash)

      if unit == :nano
        response[:balance] = raw_to_NANO(response[:balance])
        response[:pending] = raw_to_NANO(response[:pending])
      end

      response
    end

    # Reports send/receive information for accounts in wallet. Change blocks are skipped,
    # open blocks will appear as receive. Response will start with most recent blocks
    # according to local ledger.
    #
    # ==== Example:
    #
    #   wallet.history
    #
    # Example response:
    #
    #   [
    #     {
    #       "type": "send",
    #       "account": Nanook::Account,
    #       "amount": 3.2,
    #       "block_account": Nanook::Account,
    #       "hash": Nanook::Block,
    #       "local_timestamp": Time
    #     },
    #     {
    #       ...
    #     }
    #   ]
    #
    # @param unit (see #balance)
    # @return [Array<Hash{Symbol=>String|Nanook::Account|Nanook::WalletAccount|Nanook::Block|Integer|Float|Time}>]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def history(unit: Nanook.default_unit)
      validate_unit!(unit)

      rpc(:wallet_history, _access: :history, _coerce: Array).map do |h|
        h[:account] = account(h[:account])
        h[:block_account] = as_account(h[:block_account])
        h[:amount] = raw_to_NANO(h[:amount]) if unit == :nano
        h[:block] = as_block(h.delete(:hash))
        h[:local_timestamp] = as_time(h[:local_timestamp])
        h
      end
    end

    # Locks the wallet. A locked wallet cannot pocket pending transactions or make payments. See {#unlock}.
    #
    # ==== Example:
    #
    #   wallet.lock #=> true
    #
    # @return [Boolean] indicates if the wallet was successfully locked
    def lock
      rpc(:wallet_lock, _access: :locked) == 1
    end

    # Returns +true+ if the wallet is locked.
    #
    # ==== Example:
    #
    #   wallet.locked? #=> false
    #
    # @return [Boolean] indicates if the wallet is locked
    def locked?
      rpc(:wallet_locked, _access: :locked) == 1
    end

    # Unlocks a previously locked wallet.
    #
    # ==== Example:
    #
    #   wallet.unlock("new_pass") #=> true
    #
    # @return [Boolean] indicates if the unlocking action was successful
    def unlock(password = nil)
      rpc(:password_enter, password: password, _access: :valid) == 1
    end

    # Changes the password for a wallet.
    #
    # ==== Example:
    #
    #   wallet.change_password("new_pass") #=> true
    # @return [Boolean] indicates if the action was successful
    def change_password(password)
      rpc(:password_change, password: password, _access: :changed) == 1
    end

    # Tells the node to look for pending blocks for any account in the wallet.
    #
    # ==== Example:
    #
    #   wallet.search_pending #=> true
    # @return [Boolean] indicates if the action was successful
    def search_pending
      rpc(:search_pending, _access: :started) == 1
    end

    # Returns a list of pairs of {Nanook::WalletAccount} and work for wallet.
    #
    # ==== Example:
    #
    #   wallet.work
    #
    # ==== Example response:
    #
    #   {
    #     Nanook::WalletAccount: "432e5cf728c90f4f",
    #     Nanook::WalletAccount: "4efec5f63fc902cf"
    #   }
    # @return [Boolean] indicates if the action was successful
    def work
      hash = rpc(:wallet_work_get, _access: :works, _coerce: Hash).map do |account_id, work|
        [as_wallet_account(account_id), work]
      end

      Hash[hash]
    end

    private

    def rpc(action, params = {})
      check_wallet_required!

      p = { wallet: @wallet }.compact
      @rpc.call(action, p.merge(params)).tap { reset_skip_wallet_required! }
    end

    def skip_wallet_required!
      @skip_wallet_required_check = true
    end

    def reset_skip_wallet_required!
      @skip_wallet_required_check = false
    end

    def check_wallet_required!
      return if @wallet || @skip_wallet_required_check

      raise ArgumentError, 'Wallet must be present'
    end

    def validate_wallet_contains_account!(account)
      @known_valid_accounts ||= []
      return if @known_valid_accounts.include?(account)

      unless contains?(account)
        raise ArgumentError,
              "Account does not exist in wallet. Account: #{account}, wallet: #{@wallet}"
      end

      @known_valid_accounts << account
    end
  end
end
