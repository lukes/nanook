# frozen_string_literal: true

require_relative 'util'

class Nanook
  # The <tt>Nanook::WorkPeer</tt> class lets you manage your node's work peers.
  class WorkPeer
    include Nanook::Util

    def initialize(rpc)
      @rpc = rpc
    end

    def add(address:, port:)
      rpc(:work_peer_add, address: address, port: port).key?(:success)
    end

    def clear
      rpc(:work_peers_clear).key?(:success)
    end

    def to_s
      self.class.name
    end

    def list
      rpc(:work_peers, _access: :work_peers, _coerce: Array)
    end

    private

    def rpc(action, params = {})
      @rpc.call(action, params)
    end
  end
end
