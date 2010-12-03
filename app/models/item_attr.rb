require 'json'

# Each item may have a number of attributes. Each attribute for a given
# item may take on one or more of a number of possible values.
# Each subclass of ItemAttr must define a pair of methods: "value" which can parse
# a string to provide a value of the semantically relevant type, and "str" which encodes
# such a value into a string appropriate for parsing by the "value" method.
class ItemAttr < ActiveRecord::Base
  has_and_belongs_to_many :attr_sets, :join_table => "attr_set_members"
	has_many :items, :through => :attr_sets
end

module JSONItemAttr
  def value(opt, property = nil)
    value_hash = JSON.parse(opt.value_str)
    if property
      value_hash[property.to_s]
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

module DimensionsAttr
  include JSONItemAttr, LinearConversions

  def units(opt)
    value(opt, :units).to_sym
  end

  def dimension_value(opt, property, result_units)
    convert(value(opt, property).to_f, units(opt), result_units)
  end
end

class Length < ItemAttr
  include DimensionsAttr

  def value_structure
    {
      :length => :float,
      :units => [:in, :mm]
    }
  end

  def length(opt, units = :mm)
    dimension_value(opt, :length, units)
  end
end

class Area < ItemAttr
  include DimensionsAttr

  def value_structure
    {
      :length => :float,
      :width => :float,
      :units => [:in, :mm]
    }
  end

  def length(opt, units = :mm)
    dimension_value(opt, :length, units)
  end

  def width(opt, units = :mm)
    dimension_value(opt, :width, units)
  end
end

class Volume < ItemAttr
  include DimensionsAttr

  def value_structure
    {
      :height => :float,
      :width => :float,
      :depth => :float,
      :units => [:in, :mm]
    }
  end

  def height(opt, units = :mm)
    dimension_value(opt, :height, units)
  end

  def width(opt, units = :mm)
    dimension_value(opt, :width, units)
  end

  def depth(opt, units = :mm)
    dimension_value(opt, :depth, units)
  end
end

class Color < ItemAttr
  def value_structure
    :string
  end

  def color(opt)
    opt.value_str
  end
end

class Material < ItemAttr
  include JSONItemAttr, LinearConversions

  def value_structure
    {
      :color => :string,
      :thickness => :float,
      :thickness_units => [:in, :mm],
      :price => :float
    }
  end

  def color(opt)
    value(opt, :color)
  end

  def thickness(opt, units = :mm)
    convert(value(opt, :thickness).to_f, value(opt, :thickness_units).to_sym, units)
  end

  def price(opt)
    value(opt, :price)
  end
end

class EdgeBand < ItemAttr
  def value_structure
    :string
  end

  def color(opt)
    opt.value_str
  end
end