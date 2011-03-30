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

  def cost_expr(context)
    material_cost = material(Items::Panel::MATERIAL, context.color).cost_expr(H, D, context.units)
    edge_cost = edgeband_cost_expr({:front => H, :rear => D, :top => D, :bottom => D}, context.units, context.color)
    subtotal = edge_cost.map{|c| sum(material_cost, c)}.orSome(material_cost)
    item_total = apply_margin(subtotal)

    super(context).map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end
