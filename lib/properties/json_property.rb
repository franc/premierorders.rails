require 'bigdecimal'
require 'properties/json_property'

module Properties
  module JSONProperty
    def extract(json_property = nil, type = nil)
      @value_hash ||= JSON.parse(value_str)
      if json_property
        string_value = @value_hash[json_property.to_s]
        case type
          when :int   then string_value.to_i
          when :float then string_value.to_f
          when :decimal then BigDecimal.new(string_value.to_s)
          else string_value
        end
      else
        @value_hash
      end
    end
  end
end

