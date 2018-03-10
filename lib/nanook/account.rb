class Nanook

  # The <tt>Nanook::Account</tt> class contains methods to discover
  # publicly-available information about accounts on the nano network.
  #
  # Initialize this class through the convenient Nanook#account method:
  #
  #   nanook = Nanook.new
  #   account = nanook.account("xrb_...")
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   account = Nanook::Account.new(rpc_conn, "xrb_...")
  class Account

    def initialize(rpc, account)
      @rpc = rpc
      @account = account
    end

    # ===== Example response
    #   {
    #     "xrb_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd": "500000000000000000000000000000000000",
    #     "xrb_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn": "961647970820730000000000000000000000"
    #   }
    def delegators
      account_required!
      rpc(:delegators)[:delegators]
    end

    # Return boolean indicating if account is valid
    def exists?
      account_required!
      response = rpc(:validate_account_number)
      !response.empty? && response[:valid] == 1
    end

    def history(limit: 1000)
      account_required!
      rpc(:account_history, count: limit)[:history]
    end

    def public_key
      account_required!
      rpc(:account_key)[:key]
    end

    def representative
      account_required!
      rpc(:account_representative)[:representative]
    end

    # Returns a Hash containing two keys:
    #
    # * +:balance+ - Amount of {raw}[https://nano.org/en/faq#what-are-nano-units-]
    #   in the account
    # * +:pending+ - Amount of {raw}[https://nano.org/en/faq#what-are-nano-units-]
    #   pending and not yet received by the account
    # ===== Example response
    #   {
    #    "balance": "10000",
    #    "pending": "10000"
    #   }
    def balance
      account_required!
      rpc(:account_balance)
    end

    def info
      account_required!
      rpc(:account_info)
    end

    def ledger(limit: 1)
      account_required!
      rpc(:ledger, count: limit)[:accounts]
    end

    # Returns Array of block hashes
    # Or, with detailed: true, returns Hashes
    def pending(limit: 1000, detailed: false)
      account_required!

      args = { count: limit }
      args[:source] = true if detailed

      response = rpc(:pending, args)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, (detailed ? Hash : Array))
    end

    def weight
      account_required!
      rpc(:account_weight)[:weight]
    end

    private

    def rpc(action, params={})
      p = @account.nil? ? {} : { account: @account }
      @rpc.call(action, p.merge(params))
    end

    def account_required!
      if @account.nil?
        raise ArgumentError.new("Account must be present")
      end
    end

  end
end
