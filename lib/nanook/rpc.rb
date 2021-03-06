# frozen_string_literal: true

require 'json'
require 'symbolized'

class Nanook
  # The <tt>Nanook::Rpc</tt> class is responsible for maintaining the
  # connection to the RPC server, calling the RPC and parsing its response
  # into Ruby primitives.
  #
  # Internally, the {Nanook} class creates an instance of this class, and
  # it's generally more convenient to interact with the RPC through an
  # instance of {Nanook#rpc} instead of by instantiating this class directly:
  #
  #   nanook = Nanook.new
  #   nanook.rpc(:accounts_create, wallet: wallet_id, count: 2)
  class Rpc
    # Default RPC server and port to connect to.
    DEFAULT_URI = 'http://[::1]:7076'
    # Default request timeout in seconds.
    DEFAULT_TIMEOUT = 60
    # Error expected to be returned when the RPC makes a call that requires the
    # `enable_control` setting to be enabled when it is disabled.
    RPC_CONTROL_DISABLED_ERROR = 'RPC control is disabled'

    def initialize(uri = DEFAULT_URI, timeout: DEFAULT_TIMEOUT)
      @rpc_server = URI(uri)

      unless %w[http https].include?(@rpc_server.scheme)
        raise ArgumentError, "URI must have http or https in it. Was given: #{uri}"
      end

      @http = Net::HTTP.new(@rpc_server.hostname, @rpc_server.port)
      @http.read_timeout = timeout
      @request = Net::HTTP::Post.new(@rpc_server.request_uri, { 'user-agent' => "Ruby nanook gem v#{Nanook::VERSION}" })
      @request.content_type = 'application/json'
    end

    # Tests the RPC connection. Returns +true+ if connection is successful,
    # otherwise raises an exception.
    #
    # @raise [Errno::ECONNREFUSED] if connection is unsuccessful
    # @return [Boolean] true if connection is successful
    def test
      call(:telemetry)
      true
    end

    # Calls the RPC server and returns the response.
    #
    # @param action [Symbol] the "action" of the RPC to call. The RPC always
    #   expects an "action" param to identify what RPC action is being called.
    # @param params [Hash] all other params to pass to the RPC
    # @return [Hash] the response from the RPC
    def call(action, params = {})
      coerce_to = params.delete(:_coerce)
      access_as = params.delete(:_access)

      raw_hash = make_call(action, params)

      check_for_errors!(raw_hash)

      hash = parse_values(raw_hash)

      hash = hash[access_as] if access_as
      hash = coerce_empty_string_to_type(hash, coerce_to) if coerce_to

      hash
    end

    # @return [String]
    def to_s
      "#{self.class.name}(host: \"#{@rpc_server}\", timeout: #{@http.read_timeout})"
    end
    alias inspect to_s

    private

    def make_call(action, params)
      # Stringify param values
      params = params.dup.transform_values do |v|
        next v if v.is_a?(Array)

        v.to_s
      end

      @request.body = { action: action }.merge(params).to_json

      response = @http.request(@request)

      raise Nanook::ConnectionError, "Encountered net/http error #{response.code}: #{response.class.name}" \
        unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    # Raises a {Nanook::NodeRpcConfigurationError} or {Nanook::NodeRpcError} if the RPC
    # response contains an `:error` key.
    def check_for_errors!(response)
      # Raise a special error for when `enable_control` should be enabled.
      if response['error'] == RPC_CONTROL_DISABLED_ERROR
        raise Nanook::NodeRpcConfigurationError,
              'RPC must have the `enable_control` setting enabled to perform this action.'
      end

      # Raise any other error.
      raise Nanook::NodeRpcError, "An error was returned from the RPC: #{response['error']}" if response.key?('error')
    end

    # Recursively parses the RPC response, sending values to #parse_value
    def parse_values(hash)
      new_hash = hash.map do |k, val|
        new_val = case val
                  when Array
                    if val[0].is_a?(Hash)
                      val.map { |v| parse_values(v) }
                    else
                      val.map { |v| parse_value(v) }
                    end
                  when Hash
                    parse_values(val)
                  else
                    parse_value(val)
                  end

        [k, new_val]
      end

      Hash[new_hash.sort].to_symbolized_hash
    end

    # Converts Strings to primitives
    def parse_value(value)
      return value.to_i if value.match(/^\d+\Z/)
      return true if value == 'true'
      return false if value == 'false'

      value
    end

    # Converts an empty String value into an empty version of another type.
    #
    # The RPC often returns an empty String as a value to signal
    # emptiness, rather than consistent types like an empty Array,
    # or empty Hash.
    #
    # @param response the value returned from the RPC server
    # @param type the type to return an empty of
    def coerce_empty_string_to_type(response, type)
      return type.new if response == '' || response.nil?

      response
    end
  end
end
