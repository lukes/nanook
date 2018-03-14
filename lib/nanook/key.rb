class Nanook
  class Key

    def initialize(rpc, key=nil)
      @rpc = rpc
      @key = key
    end

    def generate(seed: nil, index: nil)
      if seed.nil? && index.nil?
        rpc(:key_create)
      elsif !seed.nil? && !index.nil?
        rpc(:deterministic_key, seed: seed, index: index)
      else
        raise ArgumentError.new("This method must be called with either seed AND index params given or no params")
      end
    end

    def info
      key_required!
      rpc(:key_expand)
    end

    def inspect # :nodoc:
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    private

    def rpc(action, params={})
      p = @key.nil? ? {} : { key: @key }
      @rpc.call(action, p.merge(params))
    end

    def key_required!
      if @key.nil?
        raise ArgumentError.new("Key must be present")
      end
    end

  end
end
