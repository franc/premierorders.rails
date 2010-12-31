require 'property.rb'
require 'items/item_materials.rb'

class Drawer < Item
  include ItemMaterials

  HEIGHT_DESCRIPTOR = PropertyDescriptor.new(:height, [], [Property::Height], 1)
  MATERIAL_DESCRIPTOR = PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.required_properties
    [HEIGHT_DESCRIPTOR, MATERIAL_DESCRIPTOR]
  end
  
  def calculate_price(width, depth, units, color)
    material_area = (2 * height(units) * width) + (2 * height(units) * depth)
    material_area * material(MATERIAL_DESCRIPTOR, color).price(1, 1, units)
  end

  def height(units) 
    properties.find_value(HEIGHT_DESCRIPTOR).map{|v| v.height(units)}.orLazy {
      raise "Drawers must have a fixed height. Please edit the drawer definition and set the height property."
    }
  end

  def pricing_expr(units, color)
    material_price = material(MATERIAL_DESCRIPTOR, color).pricing_expr(1, 1, units)
    "((2 * #{height(units)} * W) + (2 * #{height(units)} * W) + (D * W)) * #{material_price}"
  end
end
