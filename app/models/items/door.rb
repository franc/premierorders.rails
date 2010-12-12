require 'items/item_materials.rb'
require 'property.rb'

module PremiumDoorM
  include ItemMaterials

  # Common job item property descriptors
  DIMENSIONS = PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height])
  COLOR      = PropertyDescriptor.new(:color, [], [Property::Color], lambda {|item| item.color_options})

  # Item configuration descriptors
  STYLE_CHARGE    = PropertyDescriptor.new(:style_surcharge, [], [Property::Surcharge])
  HANDLING_CHARGE = PropertyDescriptor.new(:handling_surcharge, [], [Property::Surcharge])
  DOOR_MATERIAL   = PropertyDescriptor.new(:door_material, [], [Property::Material])
  SIZE_RANGE      = PropertyDescriptor.new(:size_range, [], [Property::SizeRange])

  def self.included(mod)
    def mod.required_properties
      [STYLE_CHARGE, HANDLING_CHARGE, DOOR_MATERIAL, SIZE_RANGE]
    end

    def mod.job_properties
      [Property::LinearUnits::DESCRIPTOR]
    end
  end

  def color_options 
    properties.find_by_descriptor(DOOR_MATERIAL).property_values.map{|m| m.color}
  end
end

class PremiumDoor < Item
  include PremiumDoorM

  def self.job_item_properties
    [DIMENSIONS, COLOR]
  end

  def price_job_item(job_item)
    units      = job_item.job.job_properties.find_by_descriptor(Property::LinearUnits::DESCRIPTOR).units
    dimensions = job_item.job_item_properties.find_by_descriptor(DIMENSIONS)
    color      = job_item.job_item_properties.find_by_descriptor(COLOR)

    calculate_price(dimensions.width(units), dimensions.height(units), units, color.color)
  end

  def calculate_price(width, height, units, color)
    style_surcharge    = properties.find_by_descriptor(STYLE_CHARGE).property_values.first.price
    handling_surcharge = properties.find_by_descriptor(HANDLING_CHARGE).property_values.first.price

    material_charge = material(DOOR_MATERIAL, color).price(length, width, units)
    material_charge + style_surcharge + handling_surcharge
  end
end

class FrenchLiteDoor < Item
  include PremiumDoorM

  DIVISIONS = PropertyDescriptor.new(:french_door_divisions, [], [Property::IntegerProperty])

  def self.job_item_properties
    [DIMENSIONS, COLOR, DIVISIONS]
  end

  def price_job_item(job_item)
    units      = job_item.job.job_properties.find_by_descriptor(Property::LinearUnits::DESCRIPTOR).units
    dimensions = job_item.job_item_properties.find_by_descriptor(DIMENSIONS)
    color      = job_item.job_item_properties.find_by_descriptor(COLOR)
    divisions  = job_item.job_item_properties.find_by_descriptor(DIVISIONS)

    calculate_price(dimensions.width(units), dimensions.height(units), units, color.color, divisions.value)
  end

  def calculate_price(width, height, units, color, divisions)
    style_surcharge    = (properties.find_by_descriptor(STYLE_CHARGE).property_values.first.price * divisions)
    handling_surcharge = properties.find_by_descriptor(HANDLING_CHARGE).property_values.first.price
    material_charge    = material(DOOR_MATERIAL, color).price(height, width, units)

    material_charge + style_surcharge + handling_surcharge
  end
end
