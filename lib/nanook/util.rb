class Nanook
  class Util

    def self.NANO_to_raw(nano)
      nano * (10**30)
    end

    def self.coerce_empty_string_to_type(response, type)
      if response == ""
        return type.new
      end

      response
    end

  end
end
