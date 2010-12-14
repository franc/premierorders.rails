require 'property.rb'

class Cabinet < Item
  DIMENSIONS_DESCRIPTOR = PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height, Property::Depth])

  def self.job_properties
    [LinearUnits::DESCRIPTOR]
  end

  def self.job_item_properties
    [DIMENSIONS_DESCRIPTOR, Color::DESCRIPTOR]
  end

  def price_job_item(job_item)
    units       = job_item.job.job_property.find_by_descriptor(LinearUnits::DESCRIPTOR)
    dimensions  = job_item.job_item_properties.find_by_descriptor(DIMENSIONS_DESCRIPTOR)
    color       = job_item.job_item_properties(find_by_descriptor(Color::DESCRIPTOR))

    item_components.inject(0.0) do |total, component|
      total + component.calculate_price(dimensions.width, dimensions.height, dimensions.depth, units.units, color.color)
    end
  end
end

class CabinetShell < ItemComponent
  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(width, height, depth, units, color)
  end
end

class CabinetDrawer < ItemComponent
  # The drawers associated with a cabinet will vary only with
  # respect to enclosing width and depth; drawer height will be fixed in
  # the drawer instance.
  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(width, depth, units, color)
  end
end
