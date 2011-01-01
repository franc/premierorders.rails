require 'property.rb'
require 'items/panel.rb'
require 'util/option.rb'

class ShellBackPanel < ItemComponent
  def self.component_types
    [Panel]
  end

  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(height, width, units, color)
  end

  def pricing_expr(units, color)
    component.pricing_expr('H', 'W', units, color)
  end
end

class ShellHorizontalPanel < ItemComponent
  include PanelPricing

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
    panel_pricing_expr('W', 'D', {:left => 'D', :right => 'D', :rear => 'W', :front => 'W'}, units, color)
  end
end

class ShellVerticalPanel < ItemComponent
  include PanelPricing

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
    panel_pricing_expr('H', 'W', {:top => 'D', :bottom => 'D', :rear => 'H', :front => 'H'}, units, color)
  end
end

