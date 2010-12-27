require 'property.rb'
require 'properties.rb'
require 'items/item_materials.rb'

class Panel < Item
  include ItemMaterials

  MATERIAL_DESCRIPTOR = PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.required_properties
    [MATERIAL_DESCRIPTOR]
  end

  # The panels associated with a shell will vary only with respect to width, length,
  # and color of material; all other possible dimensions will be fixed in the panel
  # instance.
  def calculate_price(width, length, units, color)
    material(MATERIAL_DESCRIPTOR, color).price(length, width, units)
  end
end
