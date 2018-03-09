class Nanook
  class WalletAccount

    def initialize(wallet, account, rpc)
      @wallet = wallet
      @account = account
      @rpc = rpc

      # An object to delegate account methods that don't
      # expect a wallet param in the RPC call, to allow this
      # class to support all methods that can be called on Nanook::Account
      @nanook_account_instance = Nanook::Account.new(account, rpc)

      # Wallet instance to call contains? on to check account
      # is in wallet
      @nanook_wallet_instance = Nanook::Wallet.new(wallet, rpc)

      # Contains known valid accounts in this wallet so we don't
      # need to requery
      @known_valid_accounts = []
    end

    def create
      wallet_required!
      rpc(:account_create)[:account]
    end

    def destroy
      wallet_required!
      account_required!
      rpc(:account_remove)[:removed] == 1
    end

    def pay(to:, amount:, id:)
      wallet_required!
      account_required!

      raw = Nanook::Util.NANO_to_raw(amount)

      # account is called source, so don't use the normal rpc method
      p = {
        wallet: @wallet,
        source: @account,
        destination: to,
        amount: raw,
        id: id
      }

      @rpc.call(:send, p)[:block]
    end

    # Returns false if no block to receive
    def receive(block=nil)
      wallet_required!
      account_required!

      if block.nil?
        _receive_without_block
      else
        _receive_with_block(block)
      end
    end

    # Any method of Nanook::Account can be called on this class too
    def method_missing(m, *args, &block)
      if @nanook_account_instance.respond_to?(m)
        @nanook_account_instance.send(m, *args, &block)
      else
        super(m, *args, &block)
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

    # Returns block if successful, otherwise false
    def _receive_with_block(block)
      response = rpc(:receive, block: block)[:block]
      response.nil? ? false : response
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

      # validate account is in wallet
      return if @known_valid_accounts.include?(@account)

      if @nanook_wallet_instance.contains?(@account)
        @known_valid_accounts << @account
      else
        raise ArgumentError.new("Account does not exist in wallet. Account: #{@account}, wallet: #{@wallet}")
      end
    end

  end
end
