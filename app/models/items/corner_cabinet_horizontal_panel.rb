require 'properties'

class Items::CornerCabinetHorizontalPanel < ItemComponent
  include Items::CornerCabinetPanelAssociation

  EB_SIDES = [:front, :side, :wall_side]

  def self.component_types
    [Items::Panel]
  end

  def self.required_properties
    [CORNER_SIDE_RATIO]
  end

  def self.optional_properties
    [Properties::PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def shelf_side_expr
    mult(D, term(Math.sqrt(2)))
  end

  def cost_expr(query_context)
    component.cost_expr(query_context, shelf_side_expr, shelf_side_expr).map do |panel_cost|
      edgeband_cost = edgeband_cost_expr({:front => front_width_expr, :side => side_width_expr, :wall_side => D}, query_context.units, query_context.color)
      subtotal = edgeband_cost.map{|e| panel_cost + e}.orSome(panel_cost) 

      apply_margin(subtotal)
    end
  end

  def weight_expr(query_context)
    component.weight_expr(query_context, self_side_expr, shelf_side_expr)
  end
end
