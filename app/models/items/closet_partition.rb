require 'properties'
require 'expressions'

class Items::ClosetPartition < Item
  include Items::ItemMaterials, Items::PanelEdgePricing, Items::Margins

  EDGEBAND = Properties::PropertyDescriptor.new(:edge_band, [:front, :rear, :top, :bottom], [Property::EdgeBand])

  def self.required_properties
    [Items::Panel::MATERIAL, EDGEBAND]
  end

  def material_descriptor
    Items::Panel::MATERIAL
  end

  def cost_expr(query_context)
    material_cost = material(Items::Panel::MATERIAL, query_context.color).cost_expr(H, D, query_context.units)
    edge_cost = edgeband_cost_expr({:front => H, :rear => D, :top => D, :bottom => D}, query_context.units, query_context.color)
    subtotal = edge_cost.map{|c| sum(material_cost, c)}.orSome(material_cost)
    item_total = apply_margin(subtotal)

    super.map{|e| item_total + e}.orElse(Option.some(item_total))
  end
end
