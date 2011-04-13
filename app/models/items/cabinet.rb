require 'properties'

class Items::Cabinet < Item
  def self.component_association_types
    super.merge({:required => [Items::CabinetShell], :optional => [Items::CabinetDrawer, Items::CabinetShelf]}) do |k, v1, v2|
      v1 + v2
    end
  end

  DIMENSIONS_DESCRIPTOR = Properties::PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height, Property::Depth])

  def self.job_properties
    [Property::LinearUnits::DESCRIPTOR]
  end

  def self.job_item_properties
    [DIMENSIONS_DESCRIPTOR, Property::Color::DESCRIPTOR]
  end
end
