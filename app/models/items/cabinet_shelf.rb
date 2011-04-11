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

  def qty_expr(query_context)
    r_qtys.empty? ? term(quantity) : sum(*r_qtys.map{|v| v.expr(query_context.units)})
  end

  def cost_expr(query_context)
    component.cost_expr(query_context, W, D).map do |component_cost|
      edge_cost = edgeband_cost_expr({:front => W}, query_context.units, query_context.color)
      subtotal = edge_cost.map{|c| sum(component_cost, c)}.orSome(component_cost)
      apply_margin(qty_expr(query_context) * subtotal)
    end
  end

  def weight_expr(query_context)
    component.weight_expr(query_context, W, D).map do |component_weight|
      qty_expr(query_context) * component_weight
    end
  end
end

