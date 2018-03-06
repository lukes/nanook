class NanoRpc
  class WalletAccounts

    def initialize(wallet, account, rpc)
      @wallet = wallet
      @account = account
      @rpc = rpc
    end

    def create
      wallet_required!
      rpc(:account_create)
    end

    def all
      wallet_required!
      rpc(:account_list)
    end

    def destroy
      wallet_required!
      account_required!
      rpc(:account_remove)
    end

    def pay(to:, amount:, id:)
      wallet_required!
      account_required!

      raw = NanoRpc::Util.NANO_to_raw(amount)

      # account is called source, so don't use the normal rpc method
      p = {
        wallet: @wallet,
        source: @account,
        destination: to,
        amount: raw,
        id: id
      }

      @rpc.call(:send, p)
    end

    def receive(block=nil)
      wallet_required!
      account_required!

      if block.nil?
        _receive_without_block
      else
        _receive_with_block(block)
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

    def _receive_with_block(block)
      rpc(:receive, block: block)
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

    def account_required!
      if @account.nil?
        raise ArgumentError.new("Account must be present")
      end
    end

  end
end
