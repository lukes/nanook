require 'net/http'
require 'uri'

require 'nanook/account'
require 'nanook/node'
require 'nanook/rpc'
require 'nanook/util'
require 'nanook/wallet'
require 'nanook/wallet_account'

class Nanook

  def initialize(uri=nil)
    @rpc = Nanook::Rpc.new(uri)
  end

  def node
    Nanook::Node.new(@rpc)
  end

  def wallet(wallet=nil)
    Nanook::Wallet.new(wallet, @rpc)
  end

  def account(account=nil)
    Nanook::Account.new(account, @rpc)
  end
  alias_method :accounts, :account

end
