# frozen_string_literal: true

class Nanook
  # The <tt>Nanook::PrivateKey</tt> class lets you manage your node's keys.
  class PrivateKey
    def initialize(rpc, key = nil)
      @rpc = rpc
      @key = key
    end

    def id
      @key
    end

    # @param key [Nanook::PrivateKey] private key to compare
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

    # Generate a new private public key pair. Returns the new {Nanook::PrivateKey}.
    # The public key can be retrieved by calling `#public_key` on the private key.
    #
    # ==== Examples:
    #
    #   private_key = nanook.private_key.create
    #   private_key.public_key # => Nanook::PublicKey pair for the private key
    #
    #   deterministic_private_key = nanook.private_key.create(seed: seed, index: 0)
    #
    # @param seed [String] optional seed to generate a deterministic private key.
    # @param index [Integer] optional (but required if +seed+ is given) index to generate a deterministic private key.
    # @return Nanook::PrivateKey
    def create(seed: nil, index: nil)
      response = if seed.nil?
        rpc(:key_create)
      else
        raise ArgumentError, "index argument is required when seed is given" if index.nil?
        rpc(:deterministic_key, seed: seed, index: index)
      end

      @key = response[:private]

      self
    end

    # Returns the {Nanook::Account} that matches this private key. The
    # account may not exist yet in the ledger.
    #
    # @return Nanook::Account
    def account
      Nanook::Account.new(@rpc, memoized_key_expand[:account])
    end

    # Returns the {Nanook::PublicKey} pair for this private key.
    #
    # @return Nanook::PublicKey
    def public_key
      Nanook::PublicKey.new(@rpc, memoized_key_expand[:public])
    end

    def inspect
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{format('0x00%x', (object_id << 1))}\")"
    end

    private

    def memoized_key_expand
      key_required!
      @_memoized_key_expand = rpc(:key_expand)
    end

    def rpc(action, params = {})
      p = @key.nil? ? {} : { key: @key }
      @rpc.call(action, p.merge(params))
    end

    def key_required!
      raise ArgumentError, 'Key must be present' if @key.nil?
    end
  end
end
