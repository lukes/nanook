class Nanook
  class Wallet

    def initialize(wallet, rpc)
      @wallet = wallet
      @rpc = rpc
    end

    def account(account=nil)
      Nanook::WalletAccount.new(@wallet, account, @rpc)
    end
    alias_method :accounts, :account

    def create
      rpc(:wallet_create)
    end

    def destroy
      wallet_required!
      rpc(:wallet_destroy)
    end

    def export
      wallet_required!
      rpc(:wallet_export)
    end

    def contains(account)
      wallet_required!
      rpc(:wallet_contains, account: account)
    end

    def contains?(account)
      response = contains(account)
      !response.empty? && response[:exists] == 1
    end

    def locked
      wallet_required!
      rpc(:wallet_locked)
    end

    def locked?
      response = locked
      !response.empty? && response[:locked] != 0
    end

    def all
      wallet_required!
      rpc(:account_list)
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

  end
end
