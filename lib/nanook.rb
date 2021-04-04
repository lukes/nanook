# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'forwardable'

Dir["#{File.dirname(__FILE__)}/nanook/*.rb"].sort.each { |file| require file }

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
  UNITS = %i[raw nano].freeze
  DEFAULT_UNIT = :nano

  # @return [Nanook::Rpc]
  attr_reader :rpc

  # @return [Symbol] the default unit for amounts to be in.
  #   will return {DEFAULT_UNIT} unless you define a new constant Nanook::UNIT
  #   (which must be one of {UNITS})
  def self.default_unit
    return DEFAULT_UNIT unless defined?(UNIT)

    raise Nanook::Error, "UNIT #{UNIT} must be one of #{UNITS}" unless UNITS.include?(UNIT.to_sym)

    UNIT.to_sym
  end

  # Returns a new instance of {Nanook}.
  #
  # ==== Examples:
  # Connecting to http://localhost:7076 with the default timeout of 10s:
  #   Nanook.new
  # Setting a custom timeout:
  #   Nanook.new(timeout: 10)
  # Connecting to a custom RPC host and setting a timeout:
  #   Nanook.new("http://ip6-localhost.com:7076", timeout: 10)
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
    Nanook::Account.new(@rpc, account)
  end

  # Returns a new instance of {Nanook::Block}.
  #
  # ==== Example:
  #   block = Nanook.new.block("FBF8B0E6623A31AB528EBD839EEAA91CAFD25C12294C46754E45FD017F7939EB")
  #
  # @param block [String] the id/hash of the block you want to work with
  # @return [Nanook::Block]
  def block(block)
    Nanook::Block.new(@rpc, block)
  end

  # @return [String]
  def inspect
    "#{self.class.name}(rpc: #{@rpc.inspect}, object_id: \"#{format('0x00%x', (object_id << 1))}\")"
  end

  # Returns a new instance of {Nanook::Key}.
  #
  # ==== Example:
  #   key = Nanook.new.key("3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039")
  #
  # @param key [String] a private key
  # @return [Nanook::Key]
  def key(key = nil)
    Nanook::Key.new(@rpc, key)
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
end
