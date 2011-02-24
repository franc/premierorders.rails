require 'property.rb'
require 'items/item_materials.rb'
require 'items/panel.rb'

class FinishedPanel < Item
  include ItemMaterials, PanelEdgePricing, Items::Margins

  def self.required_properties
    if self.respond_to?(:banded_edges) && !self.banded_edges.empty?
      [Panel::MATERIAL, PropertyDescriptor.new(:edge_band, banded_edges.keys, [Property::EdgeBand])]
    else
      [Panel::MATERIAL]
    end
  end

  def self.banded_edges
    {:left => L, :right => L, :top => W, :bottom => W}
  end

  def material_descriptor
    Panel::MATERIAL
  end

  def l_expr
    L
  end

  def w_expr
    W
  end

  def cost_expr(units, color, contexts)
    edgeband_cost = if !self.class.respond_to?(:banded_edges) || self.class.banded_edges.empty? 
      Option.none()
    else
      edgeband_cost_expr(self.class.banded_edges, units, color)
    end

    material_cost = material(Panel::MATERIAL, color).cost_expr(l_expr, w_expr, units)
    subtotal = edgeband_cost.map{|e| sum(material_cost, e)}.orSome(material_cost)
    item_total = apply_margin(subtotal)
    
    super(units, color, contexts).map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end

