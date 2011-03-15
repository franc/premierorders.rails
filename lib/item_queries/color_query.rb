require 'item_queries/item_query'

module ItemQueries 
  class ColorQuery < ItemQuery
    def initialize(property_family, dvinci_color_code, &value_test)
      super(Monoid::Pref.new(&value_test))
      @property_family = property_family
      @dvinci_color_code = dvinci_color_code
    end  

    def query_property(property)
      Option.iif(property.family == @property_family) do
        property.property_values.detect do |v|
          v.respond_to?(:dvinci_id) && v.dvinci_id == @dvinci_color_code
        end
      end
    end
  end

  class ColorNameQuery < ItemQuery
    def initialize(property_family, color_name, &value_test)
      super(Monoid::Uniq.new {|v1, v2| v1.color.casecmp(v2.color) == 0})
      @property_family = property_family
      @color_name = color_name
      @value_test = value_test
    end  

    def query_property(property)
      pv = Option.iif(property.family == @property_family) do
        property.property_values.detect do |v|
          v.respond_to?(:color) && 
          (v.color && @color_name) &&
          (v.color.strip.casecmp(@color_name.strip) == 0) &&
          (@value_test.nil? || @value_test.call(v))
        end
      end
    end
  end
end


