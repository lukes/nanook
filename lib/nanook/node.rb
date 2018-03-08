class Nanook
  class Node

    def initialize(rpc)
      @rpc = rpc
    end

    def block_count
      rpc(:block_count)
    end

    def block_count_type
      rpc(:block_count_type)
    end

    def bootstrap(address:, port:)
      rpc(:bootstrap, address: address, port: port)
    end

    def bootstrap_any
      rpc(:bootstrap_any)
    end

    def frontier_count
      rpc(:frontier_count)
    end

    def peers
      rpc(:peers)
    end

    def representatives
      rpc(:representatives)
    end

    def stop
      rpc(:stop)
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
