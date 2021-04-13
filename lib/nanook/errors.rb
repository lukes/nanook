# frozen_string_literal: true

class Nanook
  Error = Class.new(StandardError)

  ConnectionError = Class.new(Error)
  NanoUnitError = Class.new(Error)
  NodeRpcError = Class.new(Error)
  NodeRpcConfigurationError = Class.new(NodeRpcError)
end
