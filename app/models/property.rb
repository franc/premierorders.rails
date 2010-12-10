require 'json'

module Properties
  module Association
    def find_by_family_with_qualifier(family, qualifier)
      find(:all, :conditions => ['family = ? and qualifier = ?', family, qualifier])
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
        when :ft then (value / 25.4) / 12
        end
      when :in
        case to
        when :in then value
        when :mm then value * 25.4
        when :ft then value / 12
        end
      when :ft
        case to
        when :in then value * 12
        when :mm then value * 12 * 25.4
        when :ft then value
        end
      end
    end
  end

  module Dimensions
    include Properties::JSONProperty, Properties::LinearConversions

    def dimension_value(property, in_units, out_units)
      convert(value(property).to_f, in_units, out_units)
    end
  end
end

# Each item may have a number of properties. Each property for a given
# item may take on one or more of a number of possible values.
class Property < ActiveRecord::Base
  has_and_belongs_to_many :items
	has_and_belongs_to_many :property_values, :join_table => 'property_value_selection' 
  has_many :job_item_properties 

  def hydrate(value)
    modules.each {|mod| value.extend(mod) unless value.kind_of?(mod)}
    value
  end

  def modules
    module_names.split(/\s*,\s*/).map do |mod_name|
      Property.const_get(mod_name.to_sym)
    end
  end

  module Length
    include Properties::Dimensions

    def self.value_structure
      {
        :length => :float,
        :length_units => [:in, :mm]
      }
    end

    def length(units)
      dimension_value(:length, value(:length_units), units)
    end
  end

  module Height
    include Properties::Dimensions

    def self.value_structure
      {
        :height => :float,
        :height_units => [:in, :mm]
      }
    end

    def height(units)
      dimension_value(:width, value(:height_units), units)
    end
  end


  module Width
    include Properties::Dimensions

    def self.value_structure
      {
        :width => :float,
        :width_units => [:in, :mm]
      }
    end

    def width(units)
      dimension_value(:width, value(:width_units), units)
    end
  end

  module Depth
    include Properties::Dimensions

    def self.value_structure
      {
        :depth => :float,
        :depth_units => [:in, :mm]
      }
    end

    def depth(units)
      dimension_value(:depth, value(:depth_units), units)
    end
  end

  module Color
    include Properties::JSONProperty
    def self.value_structure
      {:color => :string}
    end

    def color
      value(:color)
    end
  end

  module Material
    include Properties::JSONProperty, Properties::LinearConversions

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

    def thickness(units)
      convert(value(:thickness).to_f, value(:thickness_units).to_sym, units)
    end

    def price(length, width, units )
      l = convert(length, units, value(:price_units).to_sym) 
      w =  convert(width, units, value(:price_units).to_sym) 
      l * w * value(:price).to_f
    end
  end

  module EdgeBand
    include Properties::JSONProperty, Properties::LinearConversions
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

    def price(length, length_units)
      convert(length, length_units, value(:price_units).to_sym) * value(:price)
    end
  end

  module Units
    include Properties::JSONProperty

    def self.value_structure
      {:units => [:in, :mm]}
    end

    def units
      value(:units).to_sym
    end
  end
end

class PropertyDescriptor
  attr_reader :family, :qualifiers, :modules
  def initialize(family, qualifiers, modules)
    @family = family
    @qualifier = qualifier
    @modules = modules
  end
end

