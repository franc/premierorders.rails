require 'json'
require 'properties.rb'

class PropertyDescriptor
  include ModularProperty
  attr_reader :family, :qualifiers, :modules
  def initialize(family, qualifiers, modules, options = nil)
    @family = family
    @qualifiers = qualifiers
    @modules = modules
    @options = options # a list of lambdas that can extract value options from an item or item_component
  end

  def options(item)
    @options.nil? ? [] : @options.call(item)
  end

  def module_names
    modules.map{|m| m.to_s.demodulize}.join(", ")
  end

  def create_property(name)
    Property.create(
      :name => name,
      :family => family,
      :module_names => module_names
    )
  end
end

# Each item may have a number of properties. Each property for a given
# item may take on one or more of a number of possible values.
class Property < ActiveRecord::Base
  include NamedModules, ModularProperty

  def self.descriptors(mod)
    descriptors = []
    descriptors += mod.required_properties if (mod.respond_to?(:required_properties))
    descriptors += mod.optional_properties if (mod.respond_to?(:optional_properties))
    descriptors
  end

  has_many :item_properties
  has_many :items, :through => :item_properties

	has_and_belongs_to_many :property_values, :join_table => 'property_value_selection' 
  has_many :job_item_properties 

  def self.search(family, term)
    Property.find_by_sql(["SELECT * FROM properties WHERE family = ? and name ILIKE ?", family, "%#{term}%"]);
  end

  module Length
    include Properties::Dimensions

    def self.value_structure
      {
        :length => :float,
        :linear_units => LinearConversion::UNITS
      }
    end

    def length(units)
      dimension_value(:length, extract(:linear_units), units)
    end
  end

  module Height
    include Properties::Dimensions

    def self.value_structure
      {
        :height => :float,
        :linear_units => Properties::LinearConversions::UNITS
      }
    end

    def height(units)
      dimension_value(:height, extract(:linear_units), units)
    end
  end

  module Width
    include Properties::Dimensions

    def self.value_structure
      {
        :width => :float,
        :linear_units => Properties::LinearConversions::UNITS
      }
    end

    def width(units)
      dimension_value(:width, extract(:linear_units), units)
    end
  end

  module Depth
    include Properties::Dimensions

    def self.value_structure
      {
        :depth => :float,
        :linear_units => Properties::LinearConversions::UNITS
      }
    end

    def depth(units)
      dimension_value(:depth, extract(:linear_units), units)
    end
  end

  module SizeRange
    include Properties::Dimensions

    def self.value_structure
      {
        :min_width  => :float,
        :max_width  => :float,
        :min_height => :float,
        :max_height => :float,
        :min_depth  => :float,
        :max_depth  => :float,
        :linear_units => Properties::LinearConversions::UNITS
      }
    end

    def value(property, units)
      dimension_value(property, extract(:linear_units), units)
    end
  end

  module Color
    include Properties::JSONProperty

    DESCRIPTOR = PropertyDescriptor.new(:color, [], [Color])

    def self.value_structure
      {:color => :string}
    end

    def color
      extract(:color)
    end
  end

  module IntegerProperty
    include Properties::JSONProperty
    def self.value_structure
      {:value => :int}
    end

    def value
      extract(:value).to_i
    end
  end

  module Margin
    include Properties::JSONProperty
    def self.value_structure
      {:factor => :float}
    end

    def factor
      extract(:factor).to_f
    end
  end

  module Surcharge
    include Properties::JSONProperty
    def self.value_structure
      {:price => :float}
    end

    def price
      extract(:price).to_f
    end
  end

  module Material
    include Properties::JSONProperty, Properties::LinearConversions

    def self.value_structure
      {
        :color => :string,
        :thickness => :float,
        :thickness_units => Properties::LinearConversions::UNITS,
        :price => :float,
        :price_units => Properties::LinearConversions::UNITS
      }
    end

    def color
      extract(:color)
    end

    def thickness(units)
      convert(extract(:thickness).to_f, extract(:thickness_units).to_sym, units)
    end

    def price(length, width, units )
      l = convert(length, units, extract(:price_units).to_sym) 
      w =  convert(width, units, extract(:price_units).to_sym) 
      l * w * extract(:price).to_f
    end
  end

  module EdgeBand
    include Properties::JSONProperty, Properties::LinearConversions
    def self.value_structure
      {
        :color => :string,
        :width => :float,
        :width_units => Properties::LinearConversions::UNITS, 
        :price => :float,
        :price_units => Properties::LinearConversions::UNITS
      }
    end

    def color
      extract(:color)
    end

    def width
      extract(:width).to_f
    end

    def price(length, length_units)
      convert(length, length_units, extract(:price_units).to_sym) * extract(:price).to_f
    end
  end

  module LinearUnits
    include Properties::JSONProperty

    DESCRIPTOR = PropertyDescriptor.new(:linear_units, [], [LinearUnits])

    def self.value_structure
      {:linear_units => Properties::LinearConversions::UNITS}
    end

    def units
      extract(:linear_units).to_sym
    end
  end
end
