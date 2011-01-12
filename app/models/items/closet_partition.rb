require 'property.rb'
require 'expressions.rb'
require 'items/panel.rb'
require 'items/item_materials.rb'

class ClosetPartition < Item
  include ItemMaterials, PanelEdgePricing, Items::Margins

  EDGEBAND = PropertyDescriptor.new(:edge_band, [:front, :rear, :top, :bottom], [Property::EdgeBand])

  def self.required_properties
    [Panel::MATERIAL, EDGEBAND]
  end

  def self.optional_properties
    [MARGIN]
  end

  def material_descriptor
    Panel::MATERIAL
  end

  def cost_expr(units, color, contexts)
    material_cost = material(Panel::MATERIAL, color).cost_expr(H, D, units)
    edge_cost = edgeband_cost_expr({:front => H, :rear => D, :top => D, :bottom => D}, units, color)
    subtotal = edge_cost.map{|c| sum(material_cost, c)}.orSome(material_cost)
    item_total = apply_margin(subtotal)

    super(units, color, contexts).map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end
