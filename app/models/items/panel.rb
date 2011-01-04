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

  def pricing_expr(units, color, l_var = 'L', w_var = 'W')
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
    component_pricing = component.pricing_expr(units, color, l_expr, w_expr)
    edge_pricing = edge_banding_pricing_expr(dimension_vars, units, color)
    apply_margin("(#{quantity} * (#{component_pricing} + #{edge_pricing}))") 
  end
end

module PanelItem
  include ItemMaterials, PanelEdgePricing, PanelMargins

  MATERIAL = PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.included(mod)
    def mod.required_properties
      [MATERIAL, PropertyDescriptor.new(:edge_band, banded_edges.keys, [Property::EdgeBand])]
    end

    def mod.optional_properties
      [MARGIN]
    end
  end

  def calculate_price(h, d, units, color)
    raise "Not yet implemented"
  end

  def material_descriptor
    MATERIAL
  end

  def pricing_expr(units, color)
    edgeband_expr = edge_banding_pricing_expr(self.class.banded_edges, units, color)
    material_expr = material(MATERIAL, color).pricing_expr(self.class.l_expr, self.class.w_expr, units)

    apply_margin("(#{edgeband_expr} + #{material_expr})")
  end
end
