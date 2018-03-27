class Nanook
  class WorkPeer

    def initialize(rpc)
      @rpc = rpc
    end

    def add(address:, port:)
      rpc(:work_peer_add, address: address, port: port).has_key?(:success)
    end

    def clear
      rpc(:work_peers_clear).has_key?(:success)
    end

    def inspect
      "#{self.class.name}(object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    def list
      rpc(:work_peers)[:work_peers]
    end

    private

    def rpc(action, params={})
      @rpc.call(action, params)
    end

  end
end
