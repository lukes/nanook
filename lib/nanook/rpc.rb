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
    # Default RPC server and port to connect to
    DEFAULT_URI = 'http://localhost:7076'
    # Default request timeout in seconds
    DEFAULT_TIMEOUT = 60

    def initialize(uri = DEFAULT_URI, timeout: DEFAULT_TIMEOUT)
      @rpc_server = URI(uri)

      unless %w[http https].include?(@rpc_server.scheme)
        raise ArgumentError, "URI must have http or https in it. Was given: #{uri}"
      end

      @http = Net::HTTP.new(@rpc_server.host, @rpc_server.port)
      @http.read_timeout = timeout
      @request = Net::HTTP::Post.new(@rpc_server.request_uri, { 'user-agent' => 'Ruby nanook gem' })
      @request.content_type = 'application/json'
    end

    # Calls the RPC server and returns the response.
    #
    # @param action [Symbol] the "action" of the RPC to call. The RPC always
    #   expects an "action" param to identify what RPC action is being called.
    # @param params [Hash] all other params to pass to the RPC
    # @return [Hash] the response from the RPC
    def call(action, params = {})
      # Stringify param values
      params = params.transform_values(&:to_s)

      @request.body = { action: action }.merge(params).to_json

      response = @http.request(@request)

      raise Nanook::Error, "Encountered net/http error #{response.code}: #{response.class.name}" \
        unless response.is_a?(Net::HTTPSuccess)

      hash = JSON.parse(response.body)
      process_hash(hash)
    end

    # @return [String]
    def inspect
      "#{self.class.name}(host: \"#{@rpc_server}\", timeout: #{@http.read_timeout} object_id: \"#{format('0x00%x',
                                                                                                         (object_id << 1))}\")"
    end

    private

    # Recursively parses the RPC response, sending values to #parse_value
    def process_hash(hash)
      new_hash = hash.map do |k, val|
        new_val = case val
                  when Array
                    if val[0].is_a?(Hash)
                      val.map { |v| process_hash(v) }
                    else
                      val.map { |v| parse_value(v) }
                    end
                  when Hash
                    process_hash(val)
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
  end
end
