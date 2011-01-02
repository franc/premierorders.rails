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

  def material_descriptor
    MATERIAL_DESCRIPTOR
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
    apply_margin("#{quantity} * ((#{component_pricing}) + (#{edge_pricing}))") 
  end
end
