require 'property.rb'
require 'items/item_materials.rb'

class ClosetPartition < Item
  include ItemMaterials, PanelEdgePricing, PanelMargins

  MATERIAL = PropertyDescriptor.new(:panel_material, [], [Property::Material])
  EDGEBAND = PropertyDescriptior.new(:edge_band, [:front, :top, :bottom], [Property::EdgeBand])

  def self.required_properties
    [MATERIAL, EDGEBAND]
  end

  def self.optional_properties
    [MARGIN]
  end

  def calculate_price(h, d, units, color)
    raise "Not yet implemented"
  end

  def pricing_expr(units, color)
    edgeband_expr = edge_banding_pricing_expr({:front => 'H', :top => 'D', :bottom => 'D'}, units, color)
    material_expr = material(MATERIAL, color).pricing_expr('H', 'D', units)

    apply_margin("(#{edgeband_expr}) + (#{material_expr})")
  end
end
