require 'property.rb'
require 'items/panel.rb'
require 'util/option.rb'
require 'expressions.rb'

class ShellHorizontalPanel < ItemComponent
  include PanelEdgePricing, Items::Margins

  def self.component_types
    [Panel]
  end

  def self.required_properties
    [PropertyDescriptor.new(:edge_band, [:left, :right, :rear, :front], [Property::EdgeBand])]
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

class ShellVerticalPanel < ItemComponent
  include PanelEdgePricing, Items::Margins

  def self.component_types
    [Panel]
  end

  def self.required_properties
    [PropertyDescriptor.new(:edge_band, [:top, :bottom, :rear, :front], [Property::EdgeBand])]
  end

  def self.optional_properties
    [MARGIN]
  end

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts, H, D).map do |component_cost|
      edge_cost = edgeband_cost_expr({:top => D, :bottom => D, :rear => H, :front => H}, units, color)
      subtotal = edge_cost.map{|c| sum(component_cost, c)}.orSome(component_cost)
      apply_margin(mult(term(quantity), subtotal))
    end
  end
end

class ShellBackPanel < ItemComponent
  include PanelEdgePricing, Items::Margins

  def self.component_types
    [Panel]
  end

  def self.optional_properties
    [MARGIN]
  end

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts, H, W).map do |component_cost|
      apply_margin(mult(term(quantity), component_cost))
    end
  end
end
