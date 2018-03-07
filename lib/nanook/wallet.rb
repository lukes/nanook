class Nanook
  class Wallet

    def initialize(wallet, rpc)
      @wallet = wallet
      @rpc = rpc
    end

    def account(account=nil)
      Nanook::WalletAccount.new(@wallet, account, @rpc)
    end

    def accounts
      wallet_required!
      rpc(:account_list)
    end

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

    def contains?(account)
      wallet_required!
      response = rpc(:wallet_contains, account: account)
      !response.empty? && response[:exists] == 1
    end

    def pay(from:, to:, amount:, id:)
      wallet_required!
      account(from).pay(to: to, amount: amount, id: id)
    end

    def receive(block=nil, into:)
      wallet_required!
      account(into).receive(block)
    end

    def locked?
      wallet_required!
      response = rpc(:wallet_locked)
      !response.empty? && response[:locked] != 0
    end

    def unlock(password)
      wallet_required!
      rpc(:password_enter, password: password)
    end

    def change_password(password)
      wallet_required!
      rpc(:password_change, password: password)
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
