require 'properties'
require 'fp'

class Items::ClosetShelf < Item
  include Items::ItemMaterials, Items::PanelEdgePricing

  EDGEBAND = Properties::PropertyDescriptor.new(:edge_band, [:front, :left, :right], [Property::EdgeBand])

  def self.required_properties
    [Items::Panel::MATERIAL, EDGEBAND]
  end

  def material_descriptor
    Items::Panel::MATERIAL
  end

  def cost_expr(query_context)
    material_cost = material(Items::Panel::MATERIAL, query_context.color).cost_expr(W, D, query_context.units)
    edgeband_cost = edgeband_cost_expr({:front => W, :left => D, :right => D}, query_context.units, query_context.color)
    subtotal = edgeband_cost.map{|e| material_cost + e}.orSome(material_cost)
    item_total = apply_margin(subtotal)

    super.map{|e| item_total + e}.orElse(Option.some(item_total))
  end
end

