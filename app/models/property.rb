require 'json'
require 'bigdecimal'
require 'fp'
require 'expressions'
require 'properties'


# Each item may have a number of properties. Each property for a given
# item may take on one or more of a number of possible values.
class Property < ActiveRecord::Base
  include Properties::NamedModules, Properties::ModularProperty

  def self.descriptors(mod, type = :all)
    descriptors = []
    descriptors += mod.required_properties if mod.respond_to?(:required_properties) && (type == :all || type == :required)
    descriptors += mod.optional_properties if mod.respond_to?(:optional_properties) && (type == :all || type == :optional)
    descriptors.sort
  end

  has_many :item_properties
  has_many :items, :through => :item_properties

	has_and_belongs_to_many :property_values, :join_table => 'property_value_selection' 
  has_many :job_item_properties 

  def self.search(family, term)
    Property.find_by_sql(["SELECT * FROM properties WHERE family = ? and name ILIKE ?", family, "%#{term}%"]);
  end

  def create_value(name, value_data = {})
    property_values.create(
      :name => name,
      :module_names => module_names,
      :value_str => JSON.generate(value_data)
    )
  end

  module Length
    include Properties::Dimensions

    def self.value_structure
      [
        [:length , :float],
        [:linear_units , Properties::LinearConversion::UNITS]
      ]
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
      [
        [:height , :float],
        [:linear_units , Properties::LinearConversions::UNITS]
      ]
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
      [
        [:width , :float],
        [:linear_units , Properties::LinearConversions::UNITS]
      ]
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
      [
        [:depth , :float],
        [:linear_units , Properties::LinearConversions::UNITS]
      ]
    end

    def depth(units = nil)
      if (units)
        dimension_value(:depth, extract(:linear_units), units)
      else
        extract(:depth).to_f
      end
    end
  end

  module Area
    include Length, Width, Expressions

    def self.value_structure
      [
        [:length, :float],
        [:length_dimension, [:L, :W, :H, :D]],
        [:width, :float],
        [:width_dimension, [:L, :W, :H, :D]],
        [:linear_units, Properties::LinearConversions::UNITS]
      ]
    end

    def dimension_var(sym)
      Option.new(extract(sym)).map do |dim|
        case dim
          when 'L' then L
          when 'W' then W
          when 'H' then H
          when 'D' then D
        end
      end
    end

    # Replace any width and length variables in the specified expression
    # with terms derived from this property value. The variables chosen
    # to be replaced can be specified by the length_dimension and width_dimension
    # attributes, or will default to L and W respectively if these are unspecified.
    def replace_variables(expr, units = nil)
      lx = Option.new(length(units)).map do |l| 
        expr.replace(dimension_var(:length_dimension).orSome(L), term(l))
      end

      wx = lambda do |ex|
        Option.new(width(units)).map {|w| ex.replace(dimension_var(:width_dimension).orSome(W), term(w))}.orSome(ex)
      end

      lx.map(&wx).orLazy{wx.call(expr)}
    end
  end

  module ScalingFactor
    def self.value_structure
      [ :factor , :float ]
    end

    def factor
      extract(:factor).to_f
    end
  end

  module SizeRange
    include Properties::Dimensions

    def self.value_structure
      [
        [:min_width  , :float],
        [:max_width  , :float],
        [:min_height , :float],
        [:max_height , :float],
        [:min_depth  , :float],
        [:max_depth  , :float],
        [:linear_units , Properties::LinearConversions::UNITS]
      ]
    end

    def value(property, units)
      dimension_value(property, extract(:linear_units), units)
    end
  end

  module Color
    include Properties::JSONProperty

    DESCRIPTOR = Properties::PropertyDescriptor.new(:color, [], [Color])

    def self.value_structure
      [
        [:color , :string],
        [:dvinci_id , :string]
      ]
    end

    def dvinci_id
      extract(:dvinci_id)
    end

    def color
      extract(:color)
    end
  end

  module IntegerProperty
    include Properties::JSONProperty
    def self.value_structure
      [[:value , :int]]
    end

    def value
      extract(:value).to_i
    end
  end

  module Margin
    include Properties::JSONProperty
    def self.value_structure
      [[:factor , :float]]
    end

    def factor
      extract(:factor).to_f
    end
  end

  module Surcharge
    include Properties::JSONProperty
    def self.value_structure
      [[:price , :decimal]]
    end

    def price
      extract(:price, :decimal)
    end
  end

  module Material
    include Expressions
    include Properties::JSONProperty, Properties::LinearConversions, Properties::SquareConversions

    def self.value_structure
      [
        [:color , :string],
        [:dvinci_id , :string],
        [:cutrite_code , :string],
        [:thickness , :float],
        [:thickness_units , Properties::LinearConversions::UNITS],
        [:price , :decimal],
        [:price_units , Properties::SquareConversions::UNITS],
        [:weight , :float],
        [:waste_factor , :float]
      ]
    end

    def color
      extract(:color)
    end

    def dvinci_id
      extract(:dvinci_id)
    end

    def cutrite_code
      extract(:cutrite_code)
    end

    def thickness(units)
      convert(extract(:thickness).to_f, extract(:thickness_units).to_sym, units)
    end

    def price_units
      extract(:price_units).to_sym
    end

    def price
      extract(:price, :decimal)
    end

    def waste_factor
      Option.fromString(extract(:waste_factor)).map{|f| f.to_f + 1.0}
    end

    def cost_expr(l_expr, w_expr, units)
      sqft_expr = l_expr * w_expr
      sqft_expr_waste = waste_factor.map{|f| sqft_expr * term(f)}.orSome(sqft_expr)
      sqft_expr_waste * term(sq_convert(price, units, price_units))
    end

    def weight_expr(l_expr, w_expr, units)
      l_expr * w_expr * term(sq_convert(extract(:weight, :decimal), units, price_units))
    end
  end

  module RangedValue
    include Expressions, Properties::JSONProperty, Properties::LinearConversions
    def self.value_structure
      [
        [:min , :float],
        [:max , :float],
        [:variable , [:height, :width, :depth]],
        [:variable_units , Properties::LinearConversions::UNITS],
        [:value , :float]
      ]
    end

    def expr(units)
      min = extract(:min)
      max = extract(:max)
      var_units = extract(:variable_units).to_sym
      var_factor = convert(1.0, var_units, units)
      var = case extract(:variable).to_sym
        when :height then H
        when :width then W
        when :depth then D
      end
      ranged(
        mult(var, term(var_factor)),
        min.blank? ? nil : term(convert(min.to_f, var_units, units)),
        max.blank? ? nil : term(convert(max.to_f, var_units, units)),
        term(extract(:value).to_f)
      )
    end
  end

  module LinearPricing
    include Expressions, Properties::JSONProperty, Properties::LinearConversions

    def self.value_structure
      [
        [:price , :decimal],
        [:price_units , Properties::LinearConversions::UNITS]
      ]
    end

    def price(units)
      convert(extract(:price, :decimal), units, extract(:price_units).to_sym)
    end

    def cost_expr(units, length_expr)
      mult(term(price(units)), length_expr)
    end
  end

  module EdgeBand
    include LinearPricing
    def self.value_structure
      [
        [:color , :string],
        [:dvinci_id , :string],
        [:cutrite_code , :string],
        [:width , :float],
        [:width_units , Properties::LinearConversions::UNITS]
      ] + LinearPricing.value_structure
    end

    def color
      extract(:color)
    end

    def dvinci_id
      extract(:dvinci_id)
    end

    def cutrite_code
      extract(:cutrite_code)
    end

    def width
      extract(:width).to_f
    end
  end

  module LinearUnits
    include Properties::JSONProperty

    DESCRIPTOR = Properties::PropertyDescriptor.new(:linear_units, [], [LinearUnits])

    def self.value_structure
      [[:linear_units , Properties::LinearConversions::UNITS]]
    end

    def units
      extract(:linear_units).to_sym
    end
  end
end
