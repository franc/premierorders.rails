require 'properties.rb'
require 'property.rb'
require 'items/cabinet_components.rb'

class Cabinet < Item
  def self.component_association_types
    [CabinetShell, CabinetDrawer]
  end

  DIMENSIONS_DESCRIPTOR = PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height, Property::Depth])

  def self.job_properties
    [Property::LinearUnits::DESCRIPTOR]
  end

  def self.job_item_properties
    [DIMENSIONS_DESCRIPTOR, Property::Color::DESCRIPTOR]
  end

  def price_job_item(job_item)
    units       = job_item.job.job_properties.find_by_descriptor(Property::LinearUnits::DESCRIPTOR)
    dimensions  = job_item.job_item_properties.find_by_descriptor(DIMENSIONS_DESCRIPTOR)
    color       = job_item.job_item_properties.find_by_descriptor(Property::Color::DESCRIPTOR)

    logger.info("units: #{units.inspect}")
    logger.info("dimensions: #{dimensions.inspect}")
    logger.info("color: #{color.inspect}")

    item_components.inject(0.0) do |total, component|
      logger.info component.inspect
      component_price = component.calculate_price(
        dimensions.width,
        dimensions.height,
        dimensions.depth,
        units.units, 
        color.color
      )

      logger.info("#{component.inspect}: #{component_price}") 
      total + component_price
    end
  end
end
