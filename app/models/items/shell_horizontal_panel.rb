require 'properties'

class Items::ShellHorizontalPanel < ItemComponent
  include Items::PanelEdgePricing, Items::Margins

  def self.component_types
    [Items::Panel]
  end

  def self.required_properties
    [Properties::PropertyDescriptor.new(:edge_band, [:left, :right, :rear, :front], [Property::EdgeBand])]
  end

  def self.optional_properties
    [MARGIN]
  end

  def cost_expr(query_context)
    component.cost_expr(query_context, W, D).map do |component_cost|
      edge_cost = edgeband_cost_expr({:left => D, :right => D, :rear => W, :front => W}, query_context.units, query_context.color)
      subtotal = edge_cost.map{|c| component_cost + c}.orSome(component_cost)
      apply_margin(qty_expr(query_context) * subtotal)
    end
  end

  def weight_expr(query_context)
    component.weight_expr(query_context, W, D).map do |component_weight|
      component_weight * qty_expr(query_context)
    end
  end
end

