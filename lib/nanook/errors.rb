# frozen_string_literal: true

class Nanook
  Error = Class.new(StandardError)
  ConnectionError = Class.new(Error)
  NanoUnitError = Class.new(Error)
  NodeRpcError = Class.new(Error) # Error returned when RPC response contains an error in payload.
  NodeRpcConfigurationError = Class.new(Error) # Error returned when `enable_control` should be enabled.
end
