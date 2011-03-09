class Items::CornerCabinet < Item
  def self.component_association_types
    super.merge({:required => [Items::CornerCabinetHorizontalPanel, Items::CornerCabinetVerticalPanels]}) do |k, v1, v2|
      v1 + v2
    end
  end
end
