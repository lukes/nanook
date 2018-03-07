class Nanook
  class Account

    def initialize(account, rpc)
      @account = account
      @rpc = rpc
    end

    def history(limit: 1000)
      account_required!
      rpc(:account_history, count: limit)
    end

    def key
      account_required!
      rpc(:account_key)
    end

    def representative
      account_required!
      rpc(:account_representative)
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
      rpc(:ledger, count: limit)
    end

    def pending(limit: 1000)
      account_required!
      rpc(:pending, count: limit)
    end

    def weight
      account_required!
      rpc(:account_weight)
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
