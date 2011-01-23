require 'property.rb'
require 'items/corner_cabinet_components.rb'

class CornerCabinet < Item
  def self.component_association_types
    super.merge({:required => [CornerCabinetHorizontalPanel, CornerCabinetVerticalPanels]}) do |k, v1, v2|
      v1 + v2
    end
  end
end
