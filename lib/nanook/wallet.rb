class Nanook

  # The <tt>Nanook::Wallet</tt> class lets you manage your nano wallets,
  # as well as some account-specific things like making and receiving payments.
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

    def initialize(rpc, wallet)
      @rpc = rpc
      @wallet = wallet
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
    # @param [String] account optional String of an account (starting with
    #   <tt>"xrb..."</tt>) to start working with. Must be an account within
    #   the wallet. When no account is given, the instance returned only
    #   allows you to call +create+ on it, to create a new account.
    # @raise [ArgumentError] if the wallet does no contain the account
    # @return [Nanook::WalletAccount]
    def account(account=nil)
      Nanook::WalletAccount.new(@rpc, @wallet, account)
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
      wallet_required!
      response = rpc(:account_list)[:accounts]
      Nanook::Util.coerce_empty_string_to_type(response, Array).map do |account|
        Nanook::WalletAccount.new(@rpc, @wallet, account)
      end
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
    # @param [Boolean] account_break_down (default is +false+). When +true+
    #  the response will contain balances per account.
    # @param unit (see Nanook::Account#balance)
    #
    # @return [Hash{Symbol=>Integer|Float|Hash}]
    def balance(account_break_down: false, unit: Nanook.default_unit)
      wallet_required!

      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      if account_break_down
        return Nanook::Util.coerce_empty_string_to_type(rpc(:wallet_balances)[:balances], Hash).tap do |r|
          if unit == :nano
            r.each do |account, balances|
              r[account][:balance] = Nanook::Util.raw_to_NANO(r[account][:balance])
              r[account][:pending] = Nanook::Util.raw_to_NANO(r[account][:pending])
            end
          end
        end
      end

      rpc(:wallet_balance_total).tap do |r|
        if unit == :nano
          r[:balance] = Nanook::Util.raw_to_NANO(r[:balance])
          r[:pending] = Nanook::Util.raw_to_NANO(r[:pending])
        end
      end
    end

    # Changes a wallet's seed.
    #
    # It's recommended to only change the seed of a wallet that contains
    # no accounts.
    #
    # ==== Example:
    #
    #   wallet.change_seed("000D1BA...") # => true
    #
    # @param seed [String] the seed to change to.
    # @return [Boolean] indicating whether the change was successful.
    def change_seed(seed)
      wallet_required!
      rpc(:wallet_change_seed, seed: seed).has_key?(:success)
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
      @wallet = rpc(:wallet_create)[:wallet]
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
      wallet_required!
      rpc(:wallet_destroy)
      true
    end

    # Generates a String containing a JSON representation of your wallet.
    #
    # ==== Example:
    #
    #   wallet.export # => "{\n    \"0000000000000000000000000000000000000000000000000000000000000000\": \"0000000000000000000000000000000000000000000000000000000000000003\",\n    \"0000000000000000000000000000000000000000000000000000000000000001\": \"C3A176FC3B90113277BFC91F55128FC9A1F1B6166A73E7446927CFFCA4C2C9D9\",\n    \"0000000000000000000000000000000000000000000000000000000000000002\": \"3E58EC805B99C52B4715598BD332C234A1FBF1780577137E18F53B9B7F85F04B\",\n    \"0000000000000000000000000000000000000000000000000000000000000003\": \"5FF8021122F3DEE0E4EC4241D35A3F41DEF63CCF6ADA66AF235DE857718498CD\",\n    \"0000000000000000000000000000000000000000000000000000000000000004\": \"A30E0A32ED41C8607AA9212843392E853FCBCB4E7CB194E35C94F07F91DE59EF\",\n    \"0000000000000000000000000000000000000000000000000000000000000005\": \"E707002E84143AA5F030A6DB8DD0C0480F2FFA75AB1FFD657EC22B5AA8E395D5\",\n    \"0000000000000000000000000000000000000000000000000000000000000006\": \"0000000000000000000000000000000000000000000000000000000000000001\",\n    \"8646C0423160DEAEAA64034F9C6858F7A5C8A329E73E825A5B16814F6CCAFFE3\": \"0000000000000000000000000000000000000000000000000000000100000000\"\n}\n"
    def export
      wallet_required!
      rpc(:wallet_export)[:json]
    end

    # Will return +true+ if the account exists in the wallet.
    #
    # ==== Example:
    #   wallet.contains?("nano_...") # => true
    #
    # @param account [String] id (will start with <tt>"nano_..."</tt>)
    # @return [Boolean] indicating if the wallet contains the given account
    def contains?(account)
      wallet_required!
      response = rpc(:wallet_contains, account: account)
      !response.empty? && response[:exists] == 1
    end

    # @return [String] the wallet id
    def id
      @wallet
    end

    # @return [String]
    def inspect
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

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
    #   wallet.pay(from: "nano_...", to: "nano_...", amount: 54000000000000, unit: :raw, id: "myUniqueId123") # => "9AE2311..."
    #
    # @param from [String] account id of an account in your wallet
    # @param to (see Nanook::WalletAccount#pay)
    # @param amount (see Nanook::WalletAccount#pay)
    # @param unit (see Nanook::Account#balance)
    # @params id (see Nanook::WalletAccount#pay)
    # @return (see Nanook::WalletAccount#pay)
    # @raise [Nanook::Error] if unsuccessful
    def pay(from:, to:, amount:, unit: Nanook.default_unit, id:)
      wallet_required!
      validate_wallet_contains_account!(from)
      account(from).pay(to: to, amount: amount, unit: unit, id: id)
    end

    # Information about pending blocks (payments) that are waiting
    # to be received by accounts in this wallet.
    #
    # See also the {#receive} method of this class for how to receive a pending payment.
    #
    # @param limit [Integer] number of accounts with pending payments to return (default is 1000)
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
    #     :nano_1111111111111111111111111111111111111111111111111117353trpda=>[
    #       "142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D",
    #       "718CC2121C3E641059BC1C2CFC45666C99E8AE922F7A807B7D07B62C995D79E2"
    #     ],
    #     :nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3=>[
    #       "4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74"
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
    #     :nano_1111111111111111111111111111111111111111111111111117353trpda=>[
    #       {
    #         :amount=>6.0,
    #         :source=>"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr",
    #         :block=>:"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D"
    #       },
    #       {
    #         :amount=>12.0,
    #         :source=>"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr",
    #         :block=>:"242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D"
    #       }
    #     ],
    #     :nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3=>[
    #       {
    #         :amount=>106.370018,
    #         :source=>"nano_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo",
    #         :block=>:"4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74"
    #       }
    #     ]
    #   }
    def pending(limit:1000, detailed:false, unit:Nanook.default_unit)
      wallet_required!

      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      params = { count: limit }
      params[:source] = true if detailed

      response = rpc(:wallet_pending, params)[:blocks]
      response = Nanook::Util.coerce_empty_string_to_type(response, Hash)

      return response unless detailed

      # Map the RPC response, which is:
      # account=>block=>[amount|source] into
      # account=>[block|amount|source]
      x = response.map do |account, data|
        new_data = data.map do |block, amount_and_source|
          d = amount_and_source.merge(block: block.to_s)
          if unit == :nano
            d[:amount] = Nanook::Util.raw_to_NANO(d[:amount])
          end
          d
        end

        [account, new_data]
      end

      Hash[x].to_symbolized_hash
    end

    # Receives a pending payment into an account in the wallet.
    #
    # When called with no +block+ argument, the latest pending payment
    # for the account will be received.
    #
    # Returns a <i>receive</i> block hash id if a receive was successful,
    # or +false+ if there were no pending payments to receive.
    #
    # You can receive a specific pending block if you know it by
    # passing the block has in as an argument.
    #
    # ==== Examples:
    #
    #   wallet.receive(into: "xrb...")               # => "9AE2311..."
    #   wallet.receive("718CC21...", into: "xrb...") # => "9AE2311..."
    #
    # @param block (see Nanook::WalletAccount#receive)
    # @param into [String] account id of account in your wallet to receive the
    #   payment into
    # @return (see Nanook::WalletAccount#receive)
    def receive(block=nil, into:)
      wallet_required!
      validate_wallet_contains_account!(into)
      account(into).receive(block)
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
    # @return [String] Representative account of the account
    def default_representative
      rpc(:wallet_representative)[:representative]
    end
    alias_method :representative, :default_representative

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
    # @param [String] representative the id of the representative account
    #   to set as this account's representative
    # @return [String] the representative account id
    # @raise [ArgumentError] if the representative account does not exist
    # @raise [Nanook::Error] if setting the representative fails
    def change_default_representative(representative)
      unless Nanook::Account.new(@rpc, representative).exists?
        raise ArgumentError.new("Representative account does not exist: #{representative}")
      end

      if rpc(:wallet_representative_set, representative: representative)[:set] == 1
        representative
      else
        raise Nanook::Error.new("Setting the representative failed")
      end
    end
    alias_method :change_representative, :change_default_representative

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
    def restore(seed, accounts:0)
      create

      unless change_seed(seed)
        raise Nanook::Error.new("Unable to set seed for wallet")
      end

      if accounts > 0
        account.create(accounts)
      end

      self
    end

    # Information about this wallet and all of its accounts.
    #
    # ==== Examples:
    #
    #   wallet.info
    #
    # Example response:
    #
    #   {
    #     id: "2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #     accounts: [
    #       {
    #         id: "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n"
    #         frontier: "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
    #         open_block: "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
    #         representative_block: "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
    #         balance: 1.45,
    #         modified_timestamp: 1511476234,
    #         block_count: 2
    #       },
    #       { ... }
    #     ]
    #   }
    #
    # @param unit (see #balance)
    # @return [Hash{Symbol=>String|Array<Hash{Symbol=>String|Integer|Float}>}] information about the wallet.
    #   See {Nanook::Account#info} for details of what is returned for each account.
    def info(unit: Nanook.default_unit)
      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      wallet_required!
      accounts = rpc(:wallet_ledger)[:accounts].map do |account_id, payload|
        payload[:id] = account_id
        if unit == :nano
          payload[:balance] = Nanook::Util.raw_to_NANO(payload[:balance])
        end
        payload
      end

      {
        id: @wallet,
        accounts: accounts
      }.to_symbolized_hash
    end

    # Locks the wallet. A locked wallet cannot pocket pending transactions or make payments. See {#unlock}.
    #
    # ==== Example:
    #
    #   wallet.lock #=> true
    #
    # @return [Boolean] indicates if the wallet was successfully locked
    def lock
      wallet_required!
      response = rpc(:wallet_lock)
      !response.empty? && response[:locked] == 1
    end

    # Returns +true+ if the wallet is locked.
    #
    # ==== Example:
    #
    #   wallet.locked? #=> false
    #
    # @return [Boolean] indicates if the wallet is locked
    def locked?
      wallet_required!
      response = rpc(:wallet_locked)
      !response.empty? && response[:locked] != 0
    end

    # Unlocks a previously locked wallet.
    #
    # ==== Example:
    #
    #   wallet.unlock("new_pass") #=> true
    #
    # @return [Boolean] indicates if the unlocking action was successful
    def unlock(password)
      wallet_required!
      rpc(:password_enter, password: password)[:valid] == 1
    end

    # Changes the password for a wallet.
    #
    # ==== Example:
    #
    #   wallet.change_password("new_pass") #=> true
    # @return [Boolean] indicates if the action was successful
    def change_password(password)
      wallet_required!
      rpc(:password_change, password: password)[:changed] == 1
    end

    private

    def rpc(action, params={})
      p = @wallet.nil? ? {} : { wallet: @wallet }
      @rpc.call(action, p.merge(params))
    end

    def wallet_required!
      if @wallet.nil?
        raise ArgumentError.new("Wallet must be present")
      end
    end

    def validate_wallet_contains_account!(account)
      @known_valid_accounts ||= []
      return if @known_valid_accounts.include?(account)

      if contains?(account)
        @known_valid_accounts << account
      else
        raise ArgumentError.new("Account does not exist in wallet. Account: #{account}, wallet: #{@wallet}")
      end
    end

  end
end
