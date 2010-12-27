require 'items/drawer.rb'
require 'items/shell.rb'

class CabinetShell < ItemComponent
  def self.component_types
    [Shell]
  end

  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(width, height, depth, units, color)
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

  # The drawers associated with a cabinet will vary only with
  # respect to enclosing width and depth; drawer height will be fixed in
  # the drawer instance.
  def calculate_price(width, height, depth, units, color)
    width_factor_prop = properties.find_by_descriptor(WIDTH_FACTOR)
    width_factor = width_factor_prop.nil? ? 1.0 : width_factor_prop.property_values.first.factor
    logger.info("quantity: #{quantity} width: #{width}, height: #{height}, depth: #{depth}, units: #{units}, width_factor: #{width_factor}")
    quantity * component.calculate_price(width * width_factor, depth, units, color)
  end
end

