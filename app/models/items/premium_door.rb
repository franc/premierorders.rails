require 'properties'
require 'expressions'
require 'fp'

module Items
  module PremiumDoorM
    include Items::ItemMaterials, Expressions

    # Common job item property descriptors
    DIMENSIONS = Properties::PropertyDescriptor.new(:dimensions,  [], [Property::Width, Property::Height])
    COLOR      = Properties::PropertyDescriptor.new(:color, [], [Property::Color], lambda {|item| item.color_opts})

    # Item configuration descriptors
    STYLE_CHARGE    = Properties::PropertyDescriptor.new(:style_surcharge, [], [Property::Surcharge])
    HANDLING_CHARGE = Properties::PropertyDescriptor.new(:handling_surcharge, [], [Property::Surcharge])
    DOOR_MATERIAL   = Properties::PropertyDescriptor.new(:door_material, [], [Property::Material])

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

    def cost_expr(query_context)
      subtotal = material_cost_expr(query_context.units, query_context.color) + 
                 term(style_surcharge) + 
                 term(handling_surcharge) 

      item_total = apply_margin(subtotal)
      Option.append(item_total, super, Semigroup::SUM)
    end

    def weight_expr(query_context)
      material_weight = material(DOOR_MATERIAL, color).weight_expr(H, W, units)
      Option.append(material_weight, super, Semigroup::SUM)
    end
  end
end


