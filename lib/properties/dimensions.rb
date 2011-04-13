require 'properties/json_property'
require 'properties/linear_conversions'

module Properties
  module Dimensions
    include Properties::JSONProperty, Properties::LinearConversions

    def dimension_value(property, in_units, out_units)
      convert(extract(property).to_f, in_units, out_units)
    end
  end
end

