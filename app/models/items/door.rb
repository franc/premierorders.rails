class PremiumDoor < Item
  include ItemMaterials

  def self.conf_properties
    [
      PropertyDescriptor.new(:style_surcharge, [], [Surcharge]),
      PropertyDescriptor.new(:handling_surcharge, [], [Surcharge]),
      PropertyDescriptor.new(:door_material, [], [Material]),
    ]
  end

  def self.job_properties
    [Units.default_descriptor]
  end

  def self.job_item_properties
    [  
      PropertyDescriptor.new(:dimensions,  [], [Width, Height]),
      PropertyDescriptor.new(:color, [], [Color], lambda {|item| item.color_options})
    ]
  end

  def color_options 
    properties.find_by_family(:door_material).property_values.map{|m| m.color}
  end

  def price_job_item(job_item)
    units = job_item.job.property(:units)
    dimensions = job_item.property(:dimensions)
    color = job_item.property(:color)

    calculate_price(dimensions.width, dimensions.height, units.units, color.color)
  end

  def calculate_price(width, height, units, color)
    style_surcharge = properties.find_by_family(:style_surcharge).price
    handling_surcharge = properties.find_by_family(:handling_surcharge).price

    material_charge = material(:door_material, color).price(length, width, units)
    material_charge + style_surcharge + handling_surcharge
  end
end

class FrenchLiteDoor < Item
  include ItemMaterials

  def self.conf_properties
    [
      PropertyDescriptor.new(:style_surcharge, [], [Surcharge]),
      PropertyDescriptor.new(:handling_surcharge, [], [Surcharge]),
      PropertyDescriptor.new(:door_material, [], [Material]),
    ]
  end

  def self.job_properties
    [Units.default_descriptor]
  end

  def self.job_item_properties
    [
      PropertyDescriptor.new(:dimensions,  [], [Width, Height]),
      PropertyDescriptor.new(:french_door_divisions, [], [IntegerProperty]),
      PropertyDescriptor.new(:color, [], [Color], lambda {|item| item.color_options})
    ]
  end

  def color_options 
    properties.find_by_family(:door_material).property_values.map{|m| m.color}
  end

  def price_job_item(job_item)
    units = job_item.job.property(:units)
    dimensions = job_item.property(:dimensions)
    color = job_item.property(:color)
    divisions = job_item.property(:french_door_divisions)

    calculate_price(dimensions.width, dimensions.height, units.units, color.color, divisions.value)
  end

  def calculate_price(width, height, units, color, divisions)
    style_surcharge = (properties.find_by_family(:style_surcharge).price * divisions)
    handling_surcharge = properties.find_by_family(:handling_surcharge).price

    material_charge = material(:door_material, color).price(length, width, units)
    material_charge + style_surcharge + handling_surcharge
  end
end
