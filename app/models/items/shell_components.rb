require 'property.rb'
require 'items/panel.rb'
require 'util/option.rb'

module ShellPanel
  MARGIN = PropertyDescriptor.new(:margin, [], [Property::Margin])

  def self.included(mod)
    def mod.component_types
      [Panel]
    end
  end

  def margin_factor
    Option.new(properties.find_by_descriptor(MARGIN)).map{|p| 1.0 + p.property_values.first.factor}
  end

  def edge_materials(sides, color)
    sides.inject({}) do |result, side|
      properties.find_by_family_with_qualifier(:edge_band, side).each do |prop|
        result[side] = prop.property_values.detect{|v| v.color == color}
      end

      result
    end
  end

  def edge_banding_pricing_expr(dimension_vars, units, color)
    exprs = []
    edge_materials(dimension_vars.keys, color).each do |side, banding|
      exprs << banding.pricing_expr(units, dimension_vars[side])
    end
    exprs.map{|e| "(#{e})"}.join(" + ")
  end

  def edge_banding_price(color, side_lengths, units)
    # Find the edge banding property value for each side
    edge_banding = edge_materials(side_lengths.keys, color)

    total = 0.0
    side_lengths.each do |side, length|
      total += edge_banding[side].calculate_price(length, units) if edge_banding[side]
    end
    total
  end

  def panel_pricing_expr(dimension_vars, units, color)
    component_pricing = component.pricing_expr('W', 'D', units, color)
    edge_pricing = edge_banding_pricing_expr(dimension_vars, units, color)
    base_expr = "#{quantity} * ((#{component_pricing}) + (#{edge_pricing}))" 
    margin_factor.map{|f| "(#{base_expr}) * #{f}"}.orSome(base_expr)
  end
end

class ShellBackPanel < ItemComponent
  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(height, width, units, color)
  end
end

class ShellHorizontalPanel < ItemComponent
  include ShellPanel

  EB_SIDES = [:left, :right, :rear, :front]

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def calculate_price(width, height, depth, units, color)
    edgeband_price = edge_banding_price(
      color, {:left => depth, :right => depth, :rear => width, :front => width}, units
    )

    unit_price = component.calculate_price(width, depth, units, color)
    quantity * (unit_price + edgeband_price) * margin_factor.orSome(1.0)
  end

  def pricing_expr(units, color)
    panel_pricing_expr({:left => 'D', :right => 'D', :rear => 'W', :front => 'W'}, units, color)
  end
end

class ShellVerticalPanel < ItemComponent
  include ShellPanel

  EB_SIDES = [:top, :bottom, :rear, :front]
  MARGIN = PropertyDescriptor.new(:margin, [], [Property::Margin])

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def calculate_price(width, height, depth, units, color)
    edgeband_price = edge_banding_price(
      color, {:top => depth, :bottom => depth, :rear => height, :front => height}, units
    )

    unit_price = component.calculate_price(depth, height, units, color)
    quantity * (unit_price + edgeband_price) * margin_factor.orSome(1.0)
  end

  def pricing_expr(units, color)
    panel_pricing_expr({:top => 'D', :bottom => 'D', :rear => 'H', :front => 'H'}, units, color)
  end
end

