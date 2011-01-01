require 'property.rb'
require 'items/item_materials.rb'

class Panel < Item
  include ItemMaterials

  MATERIAL_DESCRIPTOR = PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.required_properties
    [MATERIAL_DESCRIPTOR]
  end

  WIDTH = PropertyDescriptor.new(:width, [], [Property::Width], 1)
  LENGTH = PropertyDescriptor.new(:length, [], [Property::Length], 1)

  def self.optional_properties
    [WIDTH, LENGTH]
  end

  def width 
    properties.find_value(WIDTH).map{|v| v.width}
  end

  def length
    properties.find_value(LENGTH).map{|v| v.length}
  end

  # The panels associated with a shell will vary only with respect to width, length,
  # and color of material; all other possible dimensions will be fixed in the panel
  # instance.
  def calculate_price(w, l, units, color)
    material(MATERIAL_DESCRIPTOR, color).price(length.orSome(l), width.orSome(w), units)
  end

  def pricing_expr(l_var, w_var, units, color)
    material(MATERIAL_DESCRIPTOR, color).pricing_expr(length.orSome(l_var), width.orSome(w_var), units)
  end
end

module PanelEdgePricing
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
end

module PanelMargins
  MARGIN = PropertyDescriptor.new(:margin, [], [Property::Margin])

  def margin_factor
    properties.find_value(MARGIN).map{|v| 1.0 + v.factor}
  end
end

module PanelPricing
  include PanelEdgePricing, PanelMargins

  def self.included(mod)
    def mod.component_types
      [Panel]
    end
  end

  def panel_pricing_expr(l_expr, w_expr, dimension_vars, units, color)
    component_pricing = component.pricing_expr(l_expr, w_expr, units, color)
    edge_pricing = edge_banding_pricing_expr(dimension_vars, units, color)
    base_expr = "#{quantity} * ((#{component_pricing}) + (#{edge_pricing}))" 
    margin_factor.map{|f| "(#{base_expr}) * #{f}"}.orSome(base_expr)
  end
end
