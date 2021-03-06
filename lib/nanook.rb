# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'forwardable'

Dir["#{File.dirname(__FILE__)}/nanook/*.rb"].sort.each { |file| require file }

require_relative 'nanook/util'

# ==== Initializing
#
# Connect to the default RPC host at http://[::1]:7076 and with a timeout of 60 seconds:
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
  include Util

  UNITS = %i[raw nano].freeze
  DEFAULT_UNIT = :nano

  # @return [Nanook::Rpc]
  attr_reader :rpc

  # @return [Symbol] the default unit for amounts to be in.
  #   will return {DEFAULT_UNIT} unless you define a new constant Nanook::UNIT
  #   (which must be one of {UNITS})
  def self.default_unit
    return DEFAULT_UNIT unless defined?(UNIT)

    UNIT.to_sym
  end

  # Returns a new instance of {Nanook}.
  #
  # ==== Examples:
  # Connecting to http://[::1]:7076 with the default timeout of 60s:
  #
  #   Nanook.new
  #
  # Setting a custom timeout:
  #
  #   Nanook.new(timeout: 10)
  #
  # Connecting to a custom RPC host and setting a timeout:
  #
  #   Nanook.new("http://ip6-localhost:7076", timeout: 10)
  #
  # @param uri [String] default is {Nanook::Rpc::DEFAULT_URI}. The RPC host to connect to
  # @param timeout [Integer] default is {Nanook::Rpc::DEFAULT_TIMEOUT}. Connection timeout in number of seconds
  def initialize(uri = Nanook::Rpc::DEFAULT_URI, timeout: Nanook::Rpc::DEFAULT_TIMEOUT)
    @rpc = Nanook::Rpc.new(uri, timeout: timeout)
  end

  # Returns a new instance of {Nanook::Account}.
  #
  # ==== Example:
  #   account = Nanook.new.account("nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000")
  #
  # @param account [String] the id of the account you want to work with
  # @return [Nanook::Account]
  def account(account)
    as_account(account)
  end

  # Returns a new instance of {Nanook::Block}.
  #
  # ==== Example:
  #   block = Nanook.new.block("FBF8B0E6623A31AB528EBD839EEAA91CAFD25C12294C46754E45FD017F7939EB")
  #
  # @param block [String] the id/hash of the block you want to work with
  # @return [Nanook::Block]
  def block(block)
    as_block(block)
  end

  # @return [String]
  def to_s
    "#{self.class.name}(rpc: #{@rpc})"
  end
  alias inspect to_s

  # Returns a new instance of {Nanook::PrivateKey}.
  #
  # ==== Example:
  #   key = Nanook.new.private_key("3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039")
  #
  # @param key [String] a private key
  # @return [Nanook::PrivateKey]
  def private_key(key = nil)
    as_private_key(key, allow_blank: true)
  end

  # Returns a new instance of {Nanook::PublicKey}.
  #
  # ==== Example:
  #   key = Nanook.new.public_key("3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039")
  #
  # @param key [String] a public key
  # @return [Nanook::PublicKey]
  def public_key(key)
    as_public_key(key)
  end

  # Returns a new instance of {Nanook::Node}.
  #
  # ==== Example:
  #   node = Nanook.new.node
  #
  # @return [Nanook::Node]
  def node
    Nanook::Node.new(@rpc)
  end

  # Returns a new instance of {Nanook::Wallet}.
  #
  # ==== Example:
  #   wallet = Nanook.new.wallet("000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F")
  #
  # @param wallet [String] the id of the wallet you want to work with
  # @return [Nanook::Wallet]
  def wallet(wallet = nil)
    Nanook::Wallet.new(@rpc, wallet)
  end

  # Returns a new instance of {Nanook::WorkPeer}.
  #
  # ==== Example:
  #   work_peers = Nanook.new.work_peers
  #
  # @return [Nanook::WorkPeer]
  def work_peers
    Nanook::WorkPeer.new(@rpc)
  end

  # Return summarized metrics received from other nodes of the whole network.
  #
  # ==== Example:
  #   Nanook.new.network_telemetry
  #
  # ==== Example response:
  #   {
  #     block_count: 5777903,
  #     cemented_count: 688819,
  #     unchecked_count: 443468,
  #     account_count: 620750,
  #     bandwidth_cap: 1572864,
  #     peer_count: 32,
  #     protocol_version: 18,
  #     uptime: 556896,
  #     genesis_block: Nanook::Block,
  #     major_version: 21,
  #     minor_version: 0,
  #     patch_version: 0,
  #     pre_release_version: 0,
  #     maker: 0,
  #     timestamp: Time,
  #     active_difficulty: "ffffffcdbf40aa45"
  # }
  #
  # @return [Nanook::WorkPeer]
  def network_telemetry
    response = call_rpc(:telemetry, _coerce: Hash)
    response[:genesis_block] = as_block(response[:genesis_block])
    response[:timestamp] = as_time(response[:timestamp])
    response
  end

  private

  def call_rpc(action, params = {})
    @rpc.call(action, params)
  end
end
