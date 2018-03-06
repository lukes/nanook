require 'net/http'
require 'uri'

require 'nanook/account'
require 'nanook/rpc'
require 'nanook/util'
require 'nanook/wallet'
require 'nanook/wallet_account'

class Nanook

  def initialize(uri=nil)
    @rpc = Nanook::Rpc.new(uri)
  end

  def account(account=nil)
    Nanook::Account.new(account, @rpc)
  end
  alias_method :accounts, :account

  def wallet(wallet=nil)
    Nanook::Wallet.new(wallet, @rpc)
  end

  # These could all become dynamic
  # method name, and enforced arguments - if all of them are enforced
  # ledger and representative_set RPC calls give an example of optional args

  def block_count
    rpc(:block_count)
  end

  def block_count_type
    rpc(:block_count_type)
  end

  def bootstrap(address:, port:)
    args = Hash[method(__method__).parameters.map.collect { |_, name| [name, binding.local_variable_get(name)] }]
    rpc(:block_count_type, args)
  end

  def rpc(action, params={})
    @rpc.call(action, params)
  end

end
