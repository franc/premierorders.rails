require 'property.rb'
require 'items/corner_cabinet_components.rb'

class CornerCabinet < Item
  def self.component_association_types
    {:required => [CornerCabinetHorizontalPanel, CornerCabinetVerticalPanels]}
  end
end
