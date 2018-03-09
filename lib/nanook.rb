require 'net/http'
require 'uri'

Dir[File.dirname(__FILE__) + '/nanook/*.rb'].each {|file| require file }

class Nanook

  def initialize(uri=Nanook::Rpc::DEFAULT_URI, timeout:Nanook::Rpc::DEFAULT_TIMEOUT)
    @rpc = Nanook::Rpc.new(uri, timeout: timeout)
  end

  def account(account=nil)
    Nanook::Account.new(@rpc, account)
  end

  def block(block=nil)
    Nanook::Block.new(@rpc, block)
  end

  def key(key=nil)
    Nanook::Key.new(@rpc, key)
  end

  def node
    Nanook::Node.new(@rpc)
  end

  def wallet(wallet=nil)
    Nanook::Wallet.new(@rpc, wallet)
  end

  def work_peers
    Nanook::WorkPeer.new(@rpc)
  end

end
