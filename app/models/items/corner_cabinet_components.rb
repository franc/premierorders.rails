require 'property.rb'
require 'items/panel.rb'
require 'util/option.rb'

module CornerCabinetPanel
  include PanelEdgePricing, PanelMargins
  CORNER_SIDE_RATIO = PropertyDescriptor.new(:corner_cab_side_ratio, [], [Property::ScalingFactor])

  def self.included(mod)
    def mod.required_properties
      [CORNER_SIDE_RATIO]
    end

    def mod.component_types
      [Panel]
    end
  end

  def corner_side_ratio
    properties.find_value(CORNER_SIDE_RATIO).map{|v| v.factor}.orLazy do
      raise "Ratio of wall side to side must be specified for corner cabinet panel #{self.inspect}"
    end
  end

  def front_width(depth)
    (depth - side_width(depth)) * Math.sqrt(2)
  end

  def front_width_expr
    "((D - #{side_width_expr}) * #{Math.sqrt(2)})"
  end

  def side_width(depth)
    depth * corner_side_ratio 
  end

  def side_width_expr
    "(D * #{corner_side_ratio})"
  end
end

class CornerCabinetVerticalPanels < ItemComponent
  include CornerCabinetPanel

  EB_SIDES = [:top, :bottom, :front]

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def calculate_price(depth, units, color)
    raise "Not yet implemented."
  end

  def pricing_expr(units, color)
    side_component_expr = component.pricing_expr(units, color, 'H', side_width_expr)
    wall_side_component_expr = component.pricing_expr(units, color, 'H', 'D')
    side_edging_expr = edge_banding_pricing_expr(
      {:top => side_width_expr, :bottom => side_width_expr, :front => 'H'},
      units, color
    )

    apply_margin("(((#{side_component_expr} + #{wall_side_component_expr}) * 2) + (#{side_edging_expr} * 2))")
  end
end

class CornerCabinetHorizontalPanel < ItemComponent
  include CornerCabinetPanel

  EB_SIDES = [:front, :side, :wall_side]

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def panel_area(depth)
    (Math.sqrt(2) * depth)**2
  end

  def shelf_side_expr
    "(#{Math.sqrt(2)} * D)"
  end

  def calculate_price(depth, units, color)
    raise "Not yet implemented."
  end

  def pricing_expr(units, color)
    panel_expr = component.pricing_expr(units, color, shelf_side_expr, shelf_side_expr)
    side_edging_expr = edge_banding_pricing_expr(
      {:front => front_width_expr, :side => side_width_expr, :wall_side => 'D'},
      units, color
    )

    apply_margin("(#{panel_expr} + #{side_edging_expr})")
  end
end
