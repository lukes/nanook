class Nanook
  class Node

    def initialize(rpc)
      @rpc = rpc
    end

    def account_count
      rpc(:frontier_count)[:count]
    end
    alias_method :frontier_count, :account_count

    def block_count
      rpc(:block_count)
    end

    def block_count_type
      rpc(:block_count_type)
    end

    def bootstrap(address:, port:)
      rpc(:bootstrap, address: address, port: port).has_key?(:success)
    end

    def bootstrap_any
      rpc(:bootstrap_any).has_key?(:success)
    end

    def inspect
      "#{self.class.name}(object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    def peers
      rpc(:peers)[:peers]
    end

    def representatives
      rpc(:representatives)[:representatives]
    end

    def stop
      rpc(:stop).has_key?(:success)
    end

    def synchronizing_blocks(limit: 1000)
      response = rpc(:unchecked, count: limit)[:blocks]
      response = response.map do |block, info|
        [block, JSON.parse(info).to_symbolized_hash]
      end
      Hash[response.sort].to_symbolized_hash
    end

    def sync_progress
      response = rpc(:block_count)

      count = response[:count]
      unchecked = response[:unchecked]
      total =  count + unchecked

      count.to_f * 100 / total.to_f
    end

    def synced?
      rpc(:block_count)[:unchecked] == 0
    end

    def version
      rpc(:version)
    end

    private

    def rpc(action, params={})
      @rpc.call(action, params)
    end

  end
end
