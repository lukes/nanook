# frozen_string_literal: true

class Nanook
  # The <tt>Nanook::PublicKey</tt> class lets you manage your node's keys.
  class PublicKey
    def initialize(rpc, key)
      @rpc = rpc
      @key = key
    end

    def id
      @key
    end

    # @param key [Nanook::PublicKey] public key to compare
    # @return [Boolean] true if keys are equal
    def ==(key)
      key.class == self.class &&
        key.id == id
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
      account = rpc(:account_get)[:account]
      Nanook::Account.new(@rpc, account)
    end

    def inspect
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{format('0x00%x', (object_id << 1))}\")"
    end

    private

    def rpc(action, params = {})
      @rpc.call(action, params.merge(key: @key))
    end
  end
end
