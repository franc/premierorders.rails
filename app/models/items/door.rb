require 'items/item_materials.rb'
require 'items/panel.rb'
require 'property.rb'
require 'lib/expressions'

class Door < FinishedPanel
  include ItemMaterials, PanelEdgePricing

  def self.banded_edges
    {:left => H, :right => H, :top => W, :bottom => W}
  end

  def l_expr
    H
  end

  def w_expr
    W
  end
end

module PremiumDoorM
  include ItemMaterials, Expressions

  # Common job item property descriptors
  DIMENSIONS = PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height])
  COLOR      = PropertyDescriptor.new(:color, [], [Property::Color], lambda {|item| item.color_opts})

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

  def material_descriptor
    DOOR_MATERIAL
  end

  def handling_surcharge 
    properties.find_value(HANDLING_CHARGE).map{|v| v.price}.orLazy {
      raise "No handling surcharge property was specified for the door: #{self.inspect}"
    }
  end

  def material_cost_expr(units, color)
    material(DOOR_MATERIAL, color).cost_expr(H, W, units)
  end
end

class PremiumDoor < Item
  include PremiumDoorM

  def self.job_item_properties
    [DIMENSIONS, COLOR]
  end

  def style_surcharge 
    properties.find_value(STYLE_CHARGE).map{|v| v.price}.orLazy {
      raise "No style charge property was configured for door #{self.inspect}"
    }
  end

  def cost_expr(units, color, contexts)
    subtotal = sum(material_cost_expr(units, color), term(style_surcharge), term(handling_surcharge)) 
    item_total = apply_margin(subtotal)
    super.map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end

class PremiumDrawerfront < PremiumDoor
end

class FrenchLiteDoor < Item
  include PremiumDoorM

  DIVIDERS = PropertyDescriptor.new(:french_door_dividers, [], [Property::IntegerProperty])

  def self.job_item_properties
    [DIMENSIONS, COLOR, DIVIDERS]
  end

  def style_surcharge(divisions) 
    properties.find_value(STYLE_CHARGE).map{|v| v.price * divisions}.orLazy{
      raise "No style charge property was configured for door #{self.inspect}"
    }
  end

  def cost_expr(units, color)
    raise "Cannot generate a pricing expression for d'vinci without support for french door dividers"

    # subtotal = sum(material_cost_expr(units, color), handling_surcharge)
    # item_total = apply_margin(subtotal) 
    # super.map{|e| sum(e, item_total)}.orElse(Some(item_total))
  end
end
