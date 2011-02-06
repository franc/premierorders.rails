require 'items/drawer.rb'
require 'items/shell.rb'
require 'items/panel.rb'
require 'util/option.rb'

class CabinetShell < ItemComponent
  def self.component_types
    [Shell]
  end
end

class CabinetShelf < ItemComponent
  include PanelEdgePricing, Items::Margins

  RANGED_QTY = PropertyDescriptor.new(:qty_by_range, [], [Property::RangedValue])

  def self.component_types
    [Panel]
  end

  def self.required_properties
    [PropertyDescriptor.new(:edge_band, [:front], [Property::EdgeBand])]
  end

  def self.optional_properties
    [MARGIN, RANGED_QTY]
  end

  def r_qtys
    properties.find_all_by_descriptor(RANGED_QTY).map{|v| v.property_values}.flatten
  end

  def qty_expr(units)
    r_qtys.empty? ? term(quantity) : sum(*r_qtys.map{|v| v.expr(units)})
  end

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts, W, D).map do |component_cost|
      edge_cost = edgeband_cost_expr({:front => W}, units, color)
      subtotal = edge_cost.map{|c| sum(component_cost, c)}.orSome(component_cost)
      apply_margin(mult(qty_expr(units), subtotal))
    end
  end
end

class CabinetDrawer < ItemComponent
  WIDTH_FACTOR = PropertyDescriptor.new(:factor, [:width], [Property::ScalingFactor])

  def self.optional_properties
    [WIDTH_FACTOR]  
  end

  def self.component_types
    [Drawer]
  end

  def width_factor
    Option.new(properties.find_by_descriptor(WIDTH_FACTOR)).map{|p| p.property_values.first.factor}
  end

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts).map do |component_cost|
      width_factor.map{|f| component_cost.replace(W, mult(W, term(f)))}.orSome(component_cost)
    end
  end
end
