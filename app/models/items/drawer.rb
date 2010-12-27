require 'property.rb'
require 'items/item_materials.rb'

class Drawer < Item
  include ItemMaterials

  HEIGHT_DESCRIPTOR = PropertyDescriptor.new(:height, [], [Property::Height])
  SIDE_MATERIAL = PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.required_properties
    [HEIGHT_DESCRIPTOR, SIDE_MATERIAL]
  end
  
  def calculate_price(width, depth, units, color)
    height = unique_value(HEIGHT_DESCRIPTOR).height
    material_area = (2 * height * width) + (2 * height * depth)
    material_area * material(SIDE_MATERIAL, color).price(1, 1, units)
  end
end
