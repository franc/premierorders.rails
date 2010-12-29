require 'items/drawer.rb'
require 'items/shell.rb'
require 'util/option.rb'

class CabinetShell < ItemComponent
  def self.component_types
    [Shell]
  end

  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(width, height, depth, units, color)
  end

  def pricing_expr(units, color)
    component.pricing_expr(units, color)
  end
end

class CabinetDrawer < ItemComponent
  WIDTH_FACTOR = PropertyDescriptor.new(:factor, [:width], [Property::ScalingFactor])

  def self.optional_properties
    [WIDTH_FACTOR]  
  end

  def self.component_types
    [Drawer]
  end

  def width_factor
    Option.new(properties.find_by_descriptor(WIDTH_FACTOR)).map{|p| p.property_values.first.factor}
  end

  # The drawers associated with a cabinet will vary only with
  # respect to enclosing width and depth; drawer height will be fixed in
  # the drawer instance.
  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(width * width_factor.orSome(1.0), depth, units, color)
  end

  def pricing_expr(units, color)
    component.pricing_expr(units, color).gsub(/W/, width_factor.cata(lambda {|v| "(#{v} * W)"}, 'W'))
  end
end

