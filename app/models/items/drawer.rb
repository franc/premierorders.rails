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

  def cost_expr(query_context)
    material_unit_cost = material(Items::Panel::MATERIAL, query_context.color).cost_expr(term(1), term(1), query_context.units)
    area_expr = sum(mult(term(2), height_expr(query_context.units), sum(D, W)), mult(D, W))
    subtotal = mult(area_expr, material_unit_cost) 
    item_total = apply_margin(subtotal)

    super.map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end
