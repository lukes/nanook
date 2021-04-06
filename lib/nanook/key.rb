# frozen_string_literal: true

class Nanook
  # The <tt>Nanook::Key</tt> class lets you manage your node's keys.
  class Key
    def initialize(rpc, key = nil)
      @rpc = rpc
      @key = key
    end

    def id
      @key
    end

    # @param [Nanook::Key] key to compare
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

    def generate(seed: nil, index: nil)
      if seed.nil? && index.nil?
        rpc(:key_create)
      elsif !seed.nil? && !index.nil?
        rpc(:deterministic_key, seed: seed, index: index)
      else
        raise ArgumentError, 'This method must be called with either seed AND index params given or no params'
      end
    end

    def info
      key_required!
      rpc(:key_expand)
    end

    def inspect
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{format('0x00%x', (object_id << 1))}\")"
    end

    private

    def rpc(action, params = {})
      p = @key.nil? ? {} : { key: @key }
      @rpc.call(action, p.merge(params))
    end

    def key_required!
      raise ArgumentError, 'Key must be present' if @key.nil?
    end
  end
end
