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

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts, W, D).map do |component_cost|
      edge_cost = edgeband_cost_expr({:left => D, :right => D, :rear => W, :front => W}, units, color)
      subtotal = edge_cost.map{|c| sum(component_cost, c)}.orSome(component_cost)
      apply_margin(mult(term(quantity), subtotal))
    end
  end
end

