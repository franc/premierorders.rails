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
  def self.component_types
    [Drawer]
  end

  # The drawers associated with a cabinet will vary only with
  # respect to enclosing width and depth; drawer height will be fixed in
  # the drawer instance.
  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(width, depth, units, color)
  end
end

