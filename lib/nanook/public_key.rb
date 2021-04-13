# frozen_string_literal: true

require_relative 'util'

class Nanook
  # The <tt>Nanook::PublicKey</tt> class lets you manage your node's keys.
  class PublicKey
    include Nanook::Util

    def initialize(rpc, key)
      @rpc = rpc
      @key = key.to_s
    end

    def id
      @key
    end

    # @param other [Nanook::PublicKey] public key to compare
    # @return [Boolean] true if keys are equal
    def ==(other)
      other.class == self.class &&
        other.id == id
    end
    alias eql? ==

    # The hash value is used along with #eql? by the Hash class to determine if two objects
    # reference the same hash key.
    #
    # @return [Integer]
    def hash
      id.hash
    end

    # Returns the account for a public key
    #
    # @return [Nanook::Account] account for the public key
    def account
      account = rpc(:account_get, _access: :account)
      as_account(account)
    end

    # @return [String]
    def to_s
      "#{self.class.name}(id: \"#{short_id}\")"
    end
    alias inspect to_s

    private

    def rpc(action, params = {})
      @rpc.call(action, { key: @key }.merge(params))
    end
  end
end
