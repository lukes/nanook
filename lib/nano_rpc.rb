require 'net/http'
require 'uri'
require 'pry'

require 'nano_rpc/accounts'
require 'nano_rpc/rpc'
require 'nano_rpc/util'
require 'nano_rpc/wallet'
require 'nano_rpc/wallet_accounts'

class NanoRpc

  def initialize(uri)
    @uri = URI(uri)

    unless ['http', 'https'].include?(@uri.scheme)
      raise NanoRpc::Error.new("URI must have http or https in it. Was given: #{uri}")
    end

    @http = Net::HTTP.new(@uri.host, @uri.port)
    @request = Net::HTTP::Post.new(@uri.request_uri, {"user-agent" => "Ruby nano-rpc gem"})
    @request.content_type = "application/json"

    @rpc = NanoRpc::Rpc.new(@http, @request)
  end

  def accounts(account=nil)
    NanoRpc::Accounts.new(account, @rpc)
  end
  alias_method :account, :accounts

  def wallet(wallet=nil)
    NanoRpc::Wallet.new(wallet, @rpc)
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
