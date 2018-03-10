require 'net/http'
require 'uri'

Dir[File.dirname(__FILE__) + '/nanook/*.rb'].each {|file| require file }

# The +Nanook+ class allow
#
# ==== Initializing
#
# Connect to the default RPC host at http://localhost:7076 and with a timeout of 500 seconds:
#
#    nanook = Nanook.new
#
# To connect to another host instead:
#
#   nanook = Nanook.new("http://ip6-localhost.com:7076")
#
# To give a specific timeout value:
#
#   Nanook.new(timeout: 600)
#   Nanook.new("http://ip6-localhost.com:7076", timeout: 600)
class Nanook

  # ==== Arguments
  #
  # * +uri+ - RPC host to connect to (default is "http://localhost:7076")
  # * +timeout:+ - Connection timeout in number of seconds (default is 500)
  #
  # ==== Examples
  #
  #   Nanook.new # Connect to http://localhost:7076 with 500s timeout
  #
  #   Nanook.new(timeout: 600)
  #   Nanook.new("http://ip6-localhost.com:7076", timeout: 600)
  def initialize(uri=Nanook::Rpc::DEFAULT_URI, timeout:Nanook::Rpc::DEFAULT_TIMEOUT)
    @rpc = Nanook::Rpc.new(uri, timeout: timeout)
  end

  ##
  # Returns a Nanook::Account instance.
  #
  #   nanook = Nanook.new
  #
  #   account = nanook.account
  #   account = nanook.account("xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000")
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
