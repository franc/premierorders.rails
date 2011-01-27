require 'property.rb'
require 'items/panel.rb'
require 'util/option.rb'

module CornerCabinetPanelAssociation
  include PanelEdgePricing, Items::Margins
  CORNER_SIDE_RATIO = PropertyDescriptor.new(:corner_cab_side_ratio, [], [Property::ScalingFactor])

  def corner_side_ratio
    properties.find_value(CORNER_SIDE_RATIO).map{|v| v.factor}.orLazy do
      raise "Ratio of wall side to side must be specified for corner cabinet panel #{self.inspect}"
    end
  end

  def front_width_expr
    mult(sub(D, side_width_expr), term(Math.sqrt(2)))
  end

  def side_width_expr
    mult(D, term(corner_side_ratio))
  end
end

class CornerCabinetVerticalPanels < ItemComponent
  include CornerCabinetPanelAssociation

  EB_SIDES = [:top, :bottom, :front]

  def self.component_types
    [Panel]
  end

  def self.required_properties
    [CORNER_SIDE_RATIO]
  end

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts, H, side_width_expr).bind do |side_cost|
      component.cost_expr(units, color, contexts, H, D).map do |wall_side_cost|
        panel_cost = sum(side_cost, wall_side_cost)
        edgeband_cost = edgeband_cost_expr({:top => side_width_expr, :bottom => side_width_expr, :front => H}, units, color)
        subtotal = mult(edgeband_cost.map{|e| sum(panel_cost, e)}.orSome(panel_cost), term(2))

        apply_margin(subtotal)
      end
    end
  end
end

class CornerCabinetHorizontalPanel < ItemComponent
  include CornerCabinetPanelAssociation

  EB_SIDES = [:front, :side, :wall_side]

  def self.component_types
    [Panel]
  end

  def self.required_properties
    [CORNER_SIDE_RATIO]
  end

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def shelf_side_expr
    mult(D, term(Math.sqrt(2)))
  end

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts, shelf_side_expr, shelf_side_expr).map do |panel_cost|
      edgeband_cost = edgeband_cost_expr({:front => front_width_expr, :side => side_width_expr, :wall_side => D}, units, color)

      subtotal = edgeband_cost.map{|e| sum(panel_cost, e)}.orSome(panel_cost) 
      apply_margin(subtotal)
    end
  end
end
