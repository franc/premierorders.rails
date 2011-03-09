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

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts, H, W).map do |component_cost|
      apply_margin(mult(term(quantity), component_cost))
    end
  end
end
