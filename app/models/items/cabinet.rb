require 'property.rb'
require 'items/cabinet_components.rb'

class Cabinet < Item
  def self.component_association_types
    {:required => [CabinetShell], :optional => [CabinetDrawer, CabinetShelf]}
  end

  DIMENSIONS_DESCRIPTOR = PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height, Property::Depth])

  def self.job_properties
    [Property::LinearUnits::DESCRIPTOR]
  end

  def self.job_item_properties
    [DIMENSIONS_DESCRIPTOR, Property::Color::DESCRIPTOR]
  end
end
