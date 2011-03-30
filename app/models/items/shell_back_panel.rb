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

  def cost_expr(context)
    component.cost_expr(context, H, W).map do |component_cost|
      apply_margin(qty_expr(context) * component_cost)
    end
  end
end
