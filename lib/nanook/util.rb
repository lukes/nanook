require 'bigdecimal'

class Nanook
  class Util

    STEP = BigDecimal.new("10")**BigDecimal.new("30")

    def self.NANO_to_raw(nano)
      (BigDecimal.new(nano.to_s) * STEP).to_i
    end

    def self.raw_to_NANO(raw)
      raw.to_f / STEP
    end

    def self.coerce_empty_string_to_type(response, type)
      if response == ""
        return type.new
      end

      response
    end

  end
end
