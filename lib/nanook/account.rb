class Nanook
  class Account

    def initialize(rpc, account)
      @rpc = rpc
      @account = account
    end

    def delegators
      account_required!
      rpc(:delegators)[:delegators]
    end

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
