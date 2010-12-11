class Cabinet < Item
  def self.conf_properties
    []
  end

  def self.job_properties
    [PropertyDescriptor.new(:units,  [], [Units])]
  end

  def self.job_item_properties
    [
      PropertyDescriptor.new(:dimensions,  [], [Width, Height, Depth]),
      PropertyDescriptor.new(:color,  [], [Color])
    ]
  end

  def price_job_item(job_item)
    units       = job_item.job.property(:units)
    dimensions  = job_item.property(:dimensions)
    color       = job_item.property(:color)

    item_components.inject(0.0) do |total, component|
      total + component.calculate_price(dimensions.width, dimensions.height, dimensions.depth, units.units, color.color)
    end
  end
end

class CabinetShell < ItemComponent
  def calculate_price(width, height, depth, units, color)
    quantity * component.calculate_price(width, height, depth, units color)
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
