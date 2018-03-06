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

    def rpc(action, params={})
      @rpc.call(action, params)
    end

  end
end
