require 'net/http'
require 'uri'

require 'nanook/account'
require 'nanook/node'
require 'nanook/rpc'
require 'nanook/util'
require 'nanook/wallet'
require 'nanook/wallet_account'

class Nanook

  def initialize(uri=Nanook::Rpc::DEFAULT_URI)
    @rpc = Nanook::Rpc.new(uri)
  end

  def account(account=nil)
    Nanook::Account.new(account, @rpc)
  end

  def block(block=nil)
    Nanook::Block.new(block, @rpc)
  end

  def key(key=nil)
    Nanook::Key.new(key, @rpc)
  end

  def node
    Nanook::Node.new(@rpc)
  end

  def wallet(wallet=nil)
    Nanook::Wallet.new(wallet, @rpc)
  end

  def work_peers
    Nanook::WorkPeer.new(@rpc)
  end

end
