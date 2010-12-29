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
    height = unique_value(HEIGHT_DESCRIPTOR).height
    material_area = (2 * height * width) + (2 * height * depth)
    material_area * material(MATERIAL_DESCRIPTOR, color).price(1, 1, units)
  end

  def height(units) 
    Option.new(properties.find_by_descriptor(HEIGHT_DESCRIPTOR)).
    map{|p| p.property_values.first}.
    map{|p| p.height(units)}.
    orLazy {
      raise "Drawers must have a fixed height. Please edit the drawer definition and set the height property."
    }
  end

  def pricing_expr(units, color)
    "((2 * #{height} * W) + (2 * #{height} * W)) * #{material(MATERIAL_DESCRIPTOR, color).pricing_expr(1, 1, units)}"
  end
end
