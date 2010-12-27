require 'json'

module ModularProperty
  def value_structure
    modules.inject({}) {|vs, mod| vs.merge(mod.value_structure)}  
  end
end

module NamedModules
  def modules
    (module_names || '').split(/\s*,\s*/).map do |mod_name|
      Property.const_get(mod_name.demodulize.to_sym)
    end
  end
end

module Properties
  module Polymorphic
    include NamedModules, ModularProperty

    def morph
      modules.each {|mod| self.extend(mod) unless self.kind_of?(mod)}
    end
  end

  module Association
    def find_by_family_with_qualifier(family, qualifier)
      find(:all, :conditions => ['family = ? and qualifier = ?', family, qualifier])
    end

    def find_by_descriptor(descriptor)
      conditions = descriptor.qualifiers.empty? ? ['family = ?', descriptor.family] : ['family = ? and qualifier in (?)', descriptor.family, descriptor.qualifiers]
      find(:first, :conditions => conditions)
    end
  end

  module JSONProperty
    def extract(json_property = nil, type = nil)
      @value_hash ||= JSON.parse(value_str)
      if json_property
        string_value = @value_hash[json_property.to_s]
        case type
          when :int   then string_value.to_i
          when :float then string_value.to_f
          else string_value
        end
      else
        @value_hash
      end
    end
  end

  module LinearConversions
    UNITS = [:mm, :in, :ft]

    def convert(value, from, to)
      case from.to_sym
      when :mm
        case to.to_sym
        when :mm then value
        when :in then value / 25.4
        when :ft then (value / 25.4) / 12
        end
      when :in
        case to.to_sym
        when :in then value
        when :mm then value * 25.4
        when :ft then value / 12
        end
      when :ft
        case to.to_sym
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
      convert(extract(property).to_f, in_units, out_units)
    end
  end
end

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

    def length(units = nil)
      if (units)
        dimension_value(:length, extract(:linear_units), units)
      else
        extract(:length).to_f
      end
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

    def height(units = nil)
      if (units)
        dimension_value(:height, extract(:linear_units), units)
      else
        extract(:height).to_f
      end
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

    def width(units = nil)
      if (units)
        dimension_value(:width, extract(:linear_units), units)
      else
        extract(:width).to_f
      end
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

    def depth(units = nil)
      if (units)
        dimension_value(:depth, extract(:linear_units), units)
      else
        extract(:depth).to_f
      end
    end
  end

  module ScalingFactor
    def self.value_structure
      { :factor => :float }
    end

    def factor
      extract(:factor).to_f
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

    def price(length, width, units)
      price_units = extract(:price_units).to_sym
      l = convert(length, units, price_units) 
      w = convert(width,  units, price_units) 
      logger.info("Calculating price for l=#{l}, w=#{w}, units: #{units}, price_units: #{price_units}, price = #{extract(:price)}")
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
      logger.info("Got units: #{extract(:linear_units)}")
      extract(:linear_units).to_sym
    end
  end
end
