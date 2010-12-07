require 'json'

module PropertyUtil
  module Extensible
    def self.extended(mod)
      mod.module_eval do
        alias old_find find
      end
    end

    def find(*args)
      old_find(*args).map{|value| proxy_owner.hydrate(value)}
    end
  end

  module JSONProperty
    def value(json_property = nil)
      value_hash = JSON.parse(value_str)
      if json_property
        value_hash[json_property.to_s]
      else
        value_hash
      end
    end
  end

  module LinearConversions
    def convert(value, from, to)
      case from
      when :mm
        case to
        when :mm then value
        when :in then value / 25.4
        end
      when :in
        case to
        when :in then value
        when :mm then value * 25.4
        end
      end
    end
  end

  module Dimensions
    include JSONProperty, LinearConversions

    def dimension_value(property, in_units, out_units)
      convert(value(property).to_f, in_units, out_units)
    end
  end
end

module Properties
  module Length
    include PropertyUtil::Dimensions

    def self.value_structure
      {
        :length => :float,
        :length_units => [:in, :mm]
      }
    end

    def length(units = :mm)
      dimension_value(:length, value(:length_units), units)
    end
  end

  module Height
    include PropertyUtil::Dimensions

    def self.value_structure
      {
        :height => :float,
        :height_units => [:in, :mm]
      }
    end

    def height(units = :mm)
      dimension_value(:width, value(:height_units), units)
    end
  end


  module Width
    include PropertyUtil::Dimensions

    def self.value_structure
      {
        :width => :float,
        :width_units => [:in, :mm]
      }
    end

    def width(units = :mm)
      dimension_value(:width, value(:width_units), units)
    end
  end

  module Depth
    include PropertyUtil::Dimensions

    def self.value_structure
      {
        :depth => :float,
        :depth_units => [:in, :mm]
      }
    end

    def depth(units = :mm)
      dimension_value(:depth, value(:depth_units), units)
    end
  end

  module Color
    def self.value_structure
      :string
    end

    def color
      value_str
    end
  end

  module Material
    include PropertyUtil::JSONProperty, PropertyUtil::LinearConversions

    def self.value_structure
      {
        :color => :string,
        :thickness => :float,
        :thickness_units => [:in, :mm],
        :price => :float,
        :price_units => [:in, :mm]
      }
    end

    def color
      value(:color)
    end

    def thickness(units = :mm)
      convert(value(:thickness).to_f, value(:thickness_units).to_sym, units)
    end

    def price(length, width, units = :mm)
      convert(length, units, value(:price_units).to_sym) * convert(width, units, value(:price_units).to_sym) * value(:price).to_f
    end
  end

  module EdgeBand
    include PropertyUtil::JSONProperty, PropertyUtil::LinearConversions
    def self.value_structure
      {
        :color => :string,
        :width => :float,
        :price => :float,
        :price_units => [:in, :mm]
      }
    end

    def color
      value(:color)
    end

    def width
      value(:width)
    end

    def price(length, length_units = :mm)
      convert(length, length_units, value(:price_units).to_sym) * value(:price)
    end
  end
end

# Each item may have a number of properties. Each property for a given
# item may take on one or more of a number of possible values.
class Property < ActiveRecord::Base
  has_and_belongs_to_many :items
	has_and_belongs_to_many :property_values, :join_table => 'property_value_selection' #, :extend => PropertyUtil::Extensible
  has_many :job_item_properties #, :extend => PropertyUtil::Extensible

  def hydrate(value)
    modules.split(/\s*,\s*/).each do |mod_name|
      mod = Properties.const_get(mod_name.to_sym)
      value.extend(mod) unless value.kind_of?(mod)
    end
  end
end

