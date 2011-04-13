require 'items/premium_door'
require 'properties'

class Items::FrenchLiteDoor < Item
  include Items::PremiumDoorM

  DIVIDERS = Properties::PropertyDescriptor.new(:french_door_dividers, [], [Property::IntegerProperty])

  def self.job_item_properties
    [DIMENSIONS, COLOR, DIVIDERS]
  end

  def style_surcharge(divisions) 
    properties.find_value(STYLE_CHARGE).map{|v| v.price * divisions}.orLazy{
      raise "No style charge property was configured for door #{self.inspect}"
    }
  end

  def cost_expr(query_context)
    raise "Cannot generate a pricing expression for d'vinci without support for french door dividers"

    # subtotal = sum(material_cost_expr(units, color), handling_surcharge)
    # item_total = apply_margin(subtotal) 
    # super.map{|e| sum(e, item_total)}.orElse(Some(item_total))
  end
end

