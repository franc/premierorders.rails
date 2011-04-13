require 'fp'
require 'properties'

class Items::FinishedPanel < Item
  include Items::ItemMaterials, Items::PanelEdgePricing, Items::Margins

  def self.optional_properties
    if self.respond_to?(:banded_edges) && !self.banded_edges.empty?
      [Items::Panel::MATERIAL, Properties::PropertyDescriptor.new(:edge_band, banded_edges.keys, [Property::EdgeBand])]
    else
      [Items::Panel::MATERIAL]
    end
  end

  def self.banded_edges
    {:left => L, :right => L, :top => W, :bottom => W}
  end

  def material_descriptor
    Items::Panel::MATERIAL
  end

  def l_expr
    L
  end

  def w_expr
    W
  end

  def cost_expr(query_context)
    edgeband_cost = if !self.class.respond_to?(:banded_edges) || self.class.banded_edges.empty? 
      Option.none()
    else
      edgeband_cost_expr(self.class.banded_edges, query_context.units, query_context.color)
    end

    material_cost = material(Items::Panel::MATERIAL, query_context.color).cost_expr(l_expr, w_expr, query_context.units)
    subtotal = edgeband_cost.map{|e| sum(material_cost, e)}.orSome(material_cost)
    item_total = apply_margin(subtotal)
    
    Option.append(item_total, super, Semigroup::SUM)
  end

  def weight_expr(query_context)
    material_weight = material(Items::Panel::MATERIAL, query_context.color).weight_expr(l_expr, w_expr, query_context.units)
    Option.append(material_weight, super, Semigroup::SUM)
  end
end


