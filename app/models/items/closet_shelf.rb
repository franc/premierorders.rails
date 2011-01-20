require 'property.rb'
require 'items/item_materials.rb'
require 'items/panel.rb'

class ClosetShelf < Item
  include ItemMaterials, PanelEdgePricing

  EDGEBAND = PropertyDescriptor.new(:edge_band, [:front, :left, :right], [Property::EdgeBand])

  def self.required_properties
    [Panel::MATERIAL, EDGEBAND]
  end

  def material_descriptor
    Panel::MATERIAL
  end

  def cost_expr(units, color, contexts)
    material_cost = material(Panel::MATERIAL, color).cost_expr(W, D, units)
    edgeband_cost = edgeband_cost_expr({:front => W, :left => D, :right => D}, units, color)
    subtotal = edgeband_cost.map{|e| sum(material_cost, e)}.orSome(material_cost)
    item_total = apply_margin(subtotal)

    super.map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end

