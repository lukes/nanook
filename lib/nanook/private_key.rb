# frozen_string_literal: true

require_relative 'util'

class Nanook
  # The <tt>Nanook::PrivateKey</tt> class lets you manage your node's keys.
  class PrivateKey
    include Nanook::Util

    def initialize(rpc, key = nil)
      @rpc = rpc
      @key = key.to_s if key
    end

    def id
      @key
    end

    # @param key [Nanook::PrivateKey] private key to compare
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
      skip_key_required!

      params = {
        _access: :private,
        _coerce: Hash
      }

      @key = if seed.nil?
               rpc(:key_create, params)
             else
               raise ArgumentError, 'index argument is required when seed is given' if index.nil?

               rpc(:deterministic_key, params.merge(seed: seed, index: index))
             end

      self
    end

    # Returns the {Nanook::Account} that matches this private key. The
    # account may not exist yet in the ledger.
    #
    # @return Nanook::Account
    def account
      as_account(memoized_key_expand[:account])
    end

    # Returns the {Nanook::PublicKey} pair for this private key.
    #
    # @return Nanook::PublicKey
    def public_key
      as_public_key(memoized_key_expand[:public])
    end

    # @return [String]
    def to_s
      "#{self.class.name}(id: \"#{short_id}\")"
    end
    alias inspect to_s

    private

    def memoized_key_expand
      @memoized_key_expand ||= rpc(:key_expand, _coerce: Hash)
    end

    def rpc(action, params = {})
      check_key_required!

      p = { key: @key }.compact
      @rpc.call(action, p.merge(params)).tap { reset_skip_key_required! }
    end

    def skip_key_required!
      @skip_key_required_check = true
    end

    def reset_skip_key_required!
      @skip_key_required_check = false
    end

    def check_key_required!
      return if @key || @skip_key_required_check

      raise ArgumentError, 'Key must be present'
    end
  end
end
