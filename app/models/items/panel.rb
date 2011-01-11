require 'property.rb'
require 'items/item_materials.rb'

class Panel < Item
  include ItemMaterials

  MATERIAL = PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.required_properties
    [MATERIAL]
  end

  WIDTH  = PropertyDescriptor.new(:width, [], [Property::Width], 1)
  LENGTH = PropertyDescriptor.new(:length, [], [Property::Length], 1)

  def self.optional_properties
    super + [WIDTH, LENGTH]
  end

  def width 
    properties.find_value(WIDTH).map{|v| v.width}
  end

  def length
    properties.find_value(LENGTH).map{|v| v.length}
  end

  def material_descriptor
    MATERIAL
  end

  def cost_expr(units, color, contexts, l_expr = L, w_expr = W)
    material_cost = material(MATERIAL, color).pricing_expr(
      length.map{|l| term(l)}.orSome(l_expr), 
      width.map{|w| term(w)}.orSome(w_expr), 
      units
    )

    item_total = apply_margin(material_cost)

    super(units, color, contexts).map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end

class FinishedPanel < Item
  include ItemMaterials, PanelEdgePricing, Items::Margins

  def self.required_properties
    if self.respond_to(:banded_edges) && !self.banded_edges.empty?
      [Panel::MATERIAL, PropertyDescriptor.new(:edge_band, banded_edges.keys, [Property::EdgeBand])]
    else
      [Panel::MATERIAL]
    end
  end

  def material_descriptor
    Panel::MATERIAL
  end

  def cost_expr(units, color, contexts)
    edgeband_cost = if !self.class.respond_to(:banded_edges) || self.class.banded_edges.empty? 
      Option.none()
    else
      edgeband_cost_expr(self.class.banded_edges, units, color)
    end

    material_cost = material(Panel::MATERIAL, color).pricing_expr(self.class.l_expr, self.class.w_expr, units)
    subtotal = edgeband_cost.map{|e| sum(material_cost, e)}.orSome(material_cost)
    item_total = apply_margin(subtotal)
    
    super(units, color, contexts).map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end
