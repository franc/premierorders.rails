require 'items/item_materials.rb'

module PremiumDoorM
  include ItemMaterials

  # Job property descriptors
  DIMENSIONS_DESCRIPTOR = PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height]),
  COLOR_DESCRIPTOR    = PropertyDescriptor.new(:color, [], [Property::Color], lambda {|item| item.color_options})

  # Item configuration descriptors
  STYLE_CHARGE_DESCRIPTOR    = PropertyDescriptor.new(:style_surcharge, [], [Property::Surcharge])
  HANDLING_CHARGE_DESCRIPTOR = PropertyDescriptor.new(:handling_surcharge, [], [Property::Surcharge]),
  DOOR_MATERIAL_DESCRIPTOR   = PropertyDescriptor.new(:door_material, [], [Property::Material]),
  SIZE_RANGE_DESCRIPTOR      = PropertyDescriptor.new(:size_range, [], [Property::SizeRange])

  def self.included(mod)
    def mod.required_properties
      [
        STYLE_CHARGE_DESCRIPTOR,
        HANDLING_CHARGE_DESCRIPTOR,
        DOOR_MATERIAL_DESCRIPTOR,
        SIZE_RANGE_DESCRIPTOR
      ]
    end

    def mod.job_properties
      [LinearUnits::DESCRIPTOR]
    end
  end

  def color_options 
    properties.find_by_descriptor(DOOR_MATERIAL_DESCRIPTOR).property_values.map{|m| m.color}
  end
end

class PremiumDoor < Item
  include PremiumDoorM

  def self.job_item_properties
    [PremiumDoorM::DIMENSIONS_DESCRIPTOR, PremiumDoorM::COLOR_DESCRIPTOR]
  end

  def price_job_item(job_item)
    units      = job_item.job.job_properties.find_by_descriptor(LinearUnits::DESCRIPTOR)
    dimensions = job_item.job_item_properties.find_by_descriptor(PremiumDoorM::DIMENSIONS_DESCRIPTOR)
    color      = job_item.job_item_properties.find_by_descriptor(PremiumDoorM::COLOR_DESCRIPTOR)

    calculate_price(dimensions.width, dimensions.height, units.units, color.color)
  end

  def calculate_price(width, height, units, color)
    style_surcharge    = properties.find_by_descriptor(PremiumDoorM::STYLE_CHARGE_DESCRIPTOR).price
    handling_surcharge = properties.find_by_descriptor(PremiumDoorM::HANDLING_CHARGE_DESCRIPTOR).price

    material_charge = material(PremiumDoorM::DOOR_MATERIAL_DESCRIPTOR, color).price(length, width, units)
    material_charge + style_surcharge + handling_surcharge
  end
end

class FrenchLiteDoor < Item
  include PremiumDoorM

  DIVISIONS_DESCRIPTOR = PropertyDescriptor.new(:french_door_divisions, [], [Property::IntegerProperty]),

  def self.job_item_properties
    [PremiumDoorM::DIMENSION_DESCRIPTOR, PremiumDoorM::COLOR_DESCRIPTOR, DIVISIONS_DESCRIPTOR]
  end

  def price_job_item(job_item)
    units = job_item.job.job_properties.find_by_descriptor(LinearUnits::DESCRIPTOR)
    dimensions = job_item.job_item_properties.find_by_descriptor(DIMENSION_DESCRIPTOR)
    color      = job_item.job_item_properties.find_by_descriptor(PremiumDoorM::COLOR_DESCRIPTOR)
    divisions  = job_item.job_item_properties.find_by_descriptor(PremiumDoorM::DIVISIONS_DESCRIPTOR)

    calculate_price(dimensions.width, dimensions.height, units.units, color.color, divisions.value)
  end

  def calculate_price(width, height, units, color, divisions)
    style_surcharge    = (properties.find_by_descriptor(PremiumDoorM::STYLE_CHARGE_DESCRIPTOR).price * divisions)
    handling_surcharge = properties.find_by_descriptor(PremiumDoorM::HANDLING_CHARGE_DESCRIPTOR).price

    material_charge = material(PremiumDoorM::DOOR_MATERIAL_DESCRIPTOR, color).price(height, width, units)
    material_charge + style_surcharge + handling_surcharge
  end
end
