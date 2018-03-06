require 'json'
require 'symbolized'
require 'pry'

require 'nanook/error'

class Nanook
  class Rpc

    def initialize(http, request)
      @http = http
      @request = request
    end

    def call(action, params)
      # Stringify param values
      params = Hash[params.map {|k, v| [k, v.to_s] }]

      @request.body = { action: action }.merge(params).to_json

      response = @http.request(@request)

      if response.is_a?(Net::HTTPSuccess)
        hash = JSON.parse(response.body)
        process_hash(hash)
      else
        raise Nanook::Error.new("Encountered net/http error #{response.code}: #{response.class.name}")
      end
    end

    private

    # Convert Strings of primitives to primitives
    def process_hash(h)
      new_hash = h.map do |k,v|
        v = if v.is_a?(Array)
          if v[0].is_a?(Hash)
            v.map{|v| process_hash(v)}
          else
            v.map{|v| parse_value(v)}
          end
        else
          parse_value(v)
        end

        [k, v]
      end

      Hash[new_hash].to_symbolized_hash
    end

    def parse_value(v)
      return v.to_i if v.match(/^\d+\Z/)
      return true if v == "true"
      return false if v == "false"
      v
    end

  end
end
