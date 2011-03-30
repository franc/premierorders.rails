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

  def cost_expr(context)
    material_cost = material(Items::Panel::MATERIAL, context.color).cost_expr(W, D, context.units)
    edgeband_cost = edgeband_cost_expr({:front => W, :left => D, :right => D}, context.units, context.color)
    subtotal = edgeband_cost.map{|e| sum(material_cost, e)}.orSome(material_cost)
    item_total = apply_margin(subtotal)

    super.map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end

