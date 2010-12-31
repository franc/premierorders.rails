require 'property.rb'
require 'items/corner_cabinet_components.rb'

class CornerCabinet < Item
  def self.component_association_types
    [CornerCabinetHorizontalPanel, CornerCabinetVerticalPanels]
  end

  def calculate_price(width, height, depth, units, color)
    item_components.inject(0.0) do |total, component_conf|
      total + component_conf.calculate_price(depth, units, color)
    end
  end
end
