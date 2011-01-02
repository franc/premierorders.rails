require 'items/item_materials.rb'
require 'property.rb'

class Door < Item
  include ItemMaterials, PanelEdgePricing, PanelMargins

  MATERIAL = PropertyDescriptor.new(:panel_material, [], [Property::Material])
  EDGEBAND = PropertyDescriptor.new(:edge_band, [:left, :right, :top, :bottom], [Property::EdgeBand])

  def self.required_properties
    [MATERIAL, EDGEBAND]
  end

  def self.optional_properties
    [MARGIN]
  end

  def material_descriptor
    MATERIAL
  end

  def calculate_price(h, d, units, color)
    raise "Not yet implemented"
  end

  def pricing_expr(units, color)
    edgeband_expr = edge_banding_pricing_expr({:left => 'H', :right => 'H', :top => 'W', :bottom => 'W'}, units, color)
    material_expr = material(MATERIAL, color).pricing_expr('H', 'W', units)

    apply_margin("(#{edgeband_expr} + #{material_expr})")
  end
end

module PremiumDoorM
  include ItemMaterials

  # Common job item property descriptors
  DIMENSIONS = PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height])
  COLOR      = PropertyDescriptor.new(:color, [], [Property::Color], lambda {|item| item.color_options})

  # Item configuration descriptors
  STYLE_CHARGE    = PropertyDescriptor.new(:style_surcharge, [], [Property::Surcharge])
  HANDLING_CHARGE = PropertyDescriptor.new(:handling_surcharge, [], [Property::Surcharge])
  DOOR_MATERIAL   = PropertyDescriptor.new(:door_material, [], [Property::Material])

  def self.included(mod)
    def mod.required_properties
      [STYLE_CHARGE, HANDLING_CHARGE, DOOR_MATERIAL]
    end

    def mod.job_properties
      [Property::LinearUnits::DESCRIPTOR]
    end
  end

  def color_options 
    properties.find_by_descriptor(DOOR_MATERIAL).property_values.map{|m| m.color}
  end

  def material_descriptor
    DOOR_MATERIAL
  end

  def handling_surcharge 
    properties.find_value(HANDLING_CHARGE).map{|v| v.price}.orLazy {
      raise "No handling surcharge property was specified for the door: #{self.inspect}"
    }
  end

  def material_charge(width, height, units, color)
    material(DOOR_MATERIAL, color).price(height, width, units)
  end

  def material_pricing_expr(units, color)
    material(DOOR_MATERIAL, color).pricing_expr('H', 'W', units)
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

  def style_surcharge 
    properties.find_value(STYLE_CHARGE).map{|v| v.price}.orLazy {
      raise "No style charge property was configured for door #{self.inspect}"
    }
  end

  def calculate_price(width, height, units, color)
    material_charge(width, height, units, color) + style_surcharge + handling_surcharge
  end

  def pricing_expr(units, color)
    "(#{material_pricing_expr(units, color)} + #{style_surcharge} + #{handling_surcharge})"
  end
end

class PremiumDrawerfront < PremiumDoor
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

  def style_surcharge(divisions) 
    properties.find_value(STYLE_CHARGE).map{|v| v.price * divisions}.orLazy{
      raise "No style charge property was configured for door #{self.inspect}"
    }
  end

  def calculate_price(width, height, units, color, divisions)
    material_charge(width, height, units, color) + style_surcharge(divisions) + handling_surcharge
  end

  def pricing_expr(units, color)
    "(#{material_pricing_expr(units, color)} + #{style_surcharge(divisions)} + #{handling_surcharge})"
  end
end
