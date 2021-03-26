require 'bigdecimal'

class Nanook

  # Set of class utility methods.
  class Util

    # Constant used to convert back and forth between raw and NANO.
    STEP = BigDecimal("10")**BigDecimal("30")

    # Converts an amount of NANO to an amount of raw.
    #
    # @param nano [Float|Integer] amount in nano
    # @return [Integer] amount in raw
    def self.NANO_to_raw(nano)
      (BigDecimal(nano.to_s) * STEP).to_i
    end

    # Converts an amount of raw to an amount of NANO.
    #
    # @param raw [Integer] amount in raw
    # @return [Float|Integer] amount in NANO
    def self.raw_to_NANO(raw)
      (raw.to_f / STEP).to_f
    end

    # Converts an empty String value into an empty version of another type.
    #
    # The RPC often returns an empty String (<tt>""</tt>) as a value, when a
    # +nil+, or empty Array (<tt>[]</tt>), or empty Hash (<tt>{}</tt>) would be better.
    # If the response might be
    #
    # @param response the value returned from the RPC server
    # @param type the type to return an empty of
    def self.coerce_empty_string_to_type(response, type)
      if response == "" || response.nil?
        return type.new
      end

      response
    end

  end
end
