require 'properties'
require 'fp'

class Items::ShellBackPanel < ItemComponent
  include Items::PanelEdgePricing, Items::Margins

  def self.component_types
    [Items::Panel]
  end

  def self.optional_properties
    [MARGIN]
  end

  def cost_expr(query_context)
    component.cost_expr(query_context, H, W).map do |component_cost|
      apply_margin(qty_expr(query_context) * component_cost)
    end
  end

  def weight_expr(query_context)
    component.weight_expr(query_context, H, W).map do |component_weight|
      component_weight * qty_expr(query_context)
    end
  end
end
