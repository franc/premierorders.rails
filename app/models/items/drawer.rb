require 'properties'
require 'fp'

class Items::Drawer < Item
  include Items::ItemMaterials

  HEIGHT_DESCRIPTOR = Properties::PropertyDescriptor.new(:height, [], [Property::Height], 1)

  def self.required_properties
    [Items::Panel::MATERIAL]
  end

  def self.optional_properties
    super + [HEIGHT_DESCRIPTOR]
  end
  
  def material_descriptor
    Items::Panel::MATERIAL
  end

  def height_expr(units) 
    properties.find_value(HEIGHT_DESCRIPTOR).map{|v| term(v.height(units))}.orSome(H)
  end

  def area_expr(units)
    (term(2) * height_expr(units) * (D + W)) + (D * W)
  end

  def cost_expr(query_context)
    unit_cost = material(Items::Panel::MATERIAL, query_context.color).cost_expr(term(1), term(1), query_context.units)
    subtotal = area_expr(query_context.units) * unit_cost
    item_total = apply_margin(subtotal)

    Option.append(item_total, super, Semigroup::SUM)
  end

  def weight_expr(query_context)
    unit_weight = material(Items::Panel::MATERIAL, query_context.color).weight_expr(term(1), term(1), query_context.units)
    total_weight = area_expr(query_context.units) * unit_weight

    Option.append(total_weight, super, Semigroup::SUM)
  end
end
