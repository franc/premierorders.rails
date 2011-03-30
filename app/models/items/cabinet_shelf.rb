require 'properties'

class Items::CabinetShelf < ItemComponent
  include Items::PanelEdgePricing, Items::Margins

  RANGED_QTY = Properties::PropertyDescriptor.new(:qty_by_range, [], [Property::RangedValue])
  EDGE_BAND = Properties::PropertyDescriptor.new(:edge_band, [:front], [Property::EdgeBand])

  def self.component_types
    [Items::Panel]
  end

  def self.required_properties
    [EDGE_BAND]
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

  def cost_expr(context)
    component.cost_expr(context, W, D).map do |component_cost|
      edge_cost = edgeband_cost_expr({:front => W}, context.units, context.color)
      subtotal = edge_cost.map{|c| sum(component_cost, c)}.orSome(component_cost)
      apply_margin(mult(qty_expr(context.units), subtotal))
    end
  end
end

