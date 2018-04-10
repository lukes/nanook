class Nanook

  # The <tt>Nanook::Wallet</tt> class lets you manage your nano wallets,
  # as well as some account-specific things like making and receiving payments.
  #
  # Your wallets each have a seed, which is a 32-byte uppercase hex
  # string that looks like this:
  #
  #   000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F
  #
  # You can think of this string as your API key to the nano network.
  # The person who knows it can do all read and write actions against
  # the wallet and all accounts inside the wallet from anywhere on the
  # nano network, not just on the node you created the wallet on.
  # <b>Make sure this key is always secret and safe</b>. Do not commit
  # your seed into source control.
  #
  # === Initializing
  #
  # Initialize this class through the convenient Nanook#wallet method:
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

    # A convenient method that returns an account in your wallet, allowing
    # you to perform all the actions in Nanook::WalletAccount on it.
    #
    #   wallet.account("xrb_...") #=> Nanook::WalletAccount instance
    #
    # See Nanook::WalletAccount.
    #
    # Will throw an ArgumentError if the wallet does not contain the account.
    #
    # ==== Arguments
    # [+account+] Optional String of an account (starting with
    #             <tt>"xrb..."</tt>) to start working with. Must be an
    #             account within the wallet. When
    #             no account is given, the instance returned only allows you to call
    #             +create+ on it, to create a new account. Otherwise, you
    #             must pass an account string for all other methods.
    #
    # ==== Examples
    #
    #   wallet.account.create      # Creates an account in the wallet and returns a Nanook::WalletAccount
    #   wallet.account(account_id) # Returns a Nanook::WalletAccount for the account
    def account(account=nil)
      Nanook::WalletAccount.new(@rpc, @wallet, account)
    end

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

    # Returns a Hash containing the balance of all accounts in the
    # wallet, optionally breaking the balances down by account.
    #
    # ==== Arguments
    #
    # [+account_break_down:+] Boolean (default is +false+). When +true+
    #                         the response will contain balances per
    #                         account.
    # [+unit:+]   Symbol (default is +:nano+) Represents the unit that
    #             the balances will be returned in.
    #             Must be either +:nano+ or +:raw+. (Note: this method
    #             interprets +:nano+ as NANO, which is technically Mnano
    #             See {What are Nano's Units}[https://nano.org/en/faq#what-are-nano-units-])
    #
    # ==== Examples
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
    #     "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"=>{
    #       "balance"=>2.5,
    #       "pending"=>1
    #     },
    #     "xrb_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3sxwjym5rx"=>{
    #       "balance"=>51.4,
    #       "pending"=>0
    #     },
    #   }
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
    #
    # ==== Example:
    #   Nanook.new.wallet.create # => Nanook::Wallet
    #
    # @return [Nanook::Wallet]
    def create
      @wallet = rpc(:wallet_create)[:wallet]
      self
    end

    # Destroy the wallet. Returns a boolean indicating whether the action
    # was successful or not.
    #
    # ==== Example Response
    #   true
    def destroy
      wallet_required!
      rpc(:wallet_destroy)
      true
    end

    # Generates a String containing a JSON representation of your wallet.
    #
    # ==== Example response
    #
    #   "{\n    \"0000000000000000000000000000000000000000000000000000000000000000\": \"0000000000000000000000000000000000000000000000000000000000000003\",\n    \"0000000000000000000000000000000000000000000000000000000000000001\": \"C3A176FC3B90113277BFC91F55128FC9A1F1B6166A73E7446927CFFCA4C2C9D9\",\n    \"0000000000000000000000000000000000000000000000000000000000000002\": \"3E58EC805B99C52B4715598BD332C234A1FBF1780577137E18F53B9B7F85F04B\",\n    \"0000000000000000000000000000000000000000000000000000000000000003\": \"5FF8021122F3DEE0E4EC4241D35A3F41DEF63CCF6ADA66AF235DE857718498CD\",\n    \"0000000000000000000000000000000000000000000000000000000000000004\": \"A30E0A32ED41C8607AA9212843392E853FCBCB4E7CB194E35C94F07F91DE59EF\",\n    \"0000000000000000000000000000000000000000000000000000000000000005\": \"E707002E84143AA5F030A6DB8DD0C0480F2FFA75AB1FFD657EC22B5AA8E395D5\",\n    \"0000000000000000000000000000000000000000000000000000000000000006\": \"0000000000000000000000000000000000000000000000000000000000000001\",\n    \"8646C0423160DEAEAA64034F9C6858F7A5C8A329E73E825A5B16814F6CCAFFE3\": \"0000000000000000000000000000000000000000000000000000000100000000\"\n}\n"
    def export
      wallet_required!
      rpc(:wallet_export)[:json]
    end

    # Returns boolean indicating if the wallet contains an account.
    #
    # ==== Arguments
    #
    # [+account+] String account id (will start with <tt>"xrb_..."</tt>)
    #
    # ==== Example response
    #   true
    def contains?(account)
      wallet_required!
      response = rpc(:wallet_contains, account: account)
      !response.empty? && response[:exists] == 1
    end

    # @return [String]
    def id
      @wallet
    end

    # @return [String]
    def inspect
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    # Make a payment from an account in your wallet to another account
    # on the nano network. Returns a <i>send</i> block id
    # if successful, or a {Nanook::Error} if unsuccessful.
    #
    # Note, there may be a delay in receiving a response due to Proof of Work being done. From the {Nano RPC}[https://github.com/nanocurrency/raiblocks/wiki/RPC-protocol#account-create]:
    #
    # <i>Proof of Work is precomputed for one transaction in the background. If it has been a while since your last transaction it will send instantly, the next one will need to wait for Proof of Work to be generated.</i>
    #
    # ==== Examples
    #
    #   wallet.pay(from: "xrb_...", to: "xrb_...", amount: 1.1, id: "myUniqueId123") # => "9AE2311..."
    #   wallet.pay(from: "xrb_...", to: "xrb_...", amount: 54000000000000, unit: :raw, id: "myUniqueId123") # => "9AE2311..."
    #
    # ==== Arguments
    #
    # @param from [String] account id of an account in your wallet
    # @param to (see Nanook::WalletAccount#pay)
    # @param amount (see Nanook::WalletAccount#pay)
    # @param unit (see Nanook::Account#balance)
    # @params id (see Nanook::WalletAccount#pay)
    # @return (see Nanook::WalletAccount#pay)
    def pay(from:, to:, amount:, unit: Nanook.default_unit, id:)
      wallet_required!
      validate_wallet_contains_account!(from)
      account(from).pay(to: to, amount: amount, unit: unit, id: id)
    end

    # Returns information about pending blocks (payments) that are waiting
    # to be received by accounts in this wallet.
    #
    # See also the #receive method of this class for how to receive a pending payment.
    #
    # @param limit [Integer] number of accounts with pending payments to return (default is 1000)
    # @param detailed [Boolean]return a more complex Hash of pending block information (default is +false+)
    # @param unit (see Nanook::Account#balance)
    #
    # ==== Example 1:
    #
    #   wallet.pending
    #
    # ==== Example 1 response:
    #   {
    #     :xrb_1111111111111111111111111111111111111111111111111117353trpda=>[
    #       "142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D",
    #       "718CC2121C3E641059BC1C2CFC45666C99E8AE922F7A807B7D07B62C995D79E2"
    #     ],
    #     :xrb_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3=>[
    #       "4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74"
    #     ]
    #   }
    # ==== Example 2:
    #
    #   wallet.pending(detailed: true)
    #
    # ==== Example 2 response:
    #   {
    #     :xrb_1111111111111111111111111111111111111111111111111117353trpda=>[
    #       {
    #         :amount=>6.0,
    #         :source=>"xrb_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr",
    #         :block=>:"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D"
    #       },
    #       {
    #         :amount=>12.0,
    #         :source=>"xrb_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr",
    #         :block=>:"242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D"
    #       }
    #     ],
    #     :xrb_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3=>[
    #       {
    #         :amount=>106.370018,
    #         :source=>"xrb_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo",
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
    # Returns a <i>receive</i> block hash
    # if a receive was successful, or +false+ if there were no pending
    # payments to receive.
    #
    # You can receive a specific pending block if you know it by
    # passing the block has in as an argument.
    #
    # ==== Examples
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

    # Restore a previously created wallet by its seed.
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

    # Returns a boolean to indicate if the wallet is locked.
    #
    # ==== Example response
    #
    #   true
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
    # @return [Boolean] indicates if the action was successful
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
