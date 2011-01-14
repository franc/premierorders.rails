require 'property.rb'
require 'items/item_materials.rb'
require 'items/panel.rb'
require 'util/option'

class Drawer < Item
  include ItemMaterials

  HEIGHT_DESCRIPTOR = PropertyDescriptor.new(:height, [], [Property::Height], 1)

  def self.required_properties
    [HEIGHT_DESCRIPTOR, Panel::MATERIAL]
  end
  
  def material_descriptor
    Panel::MATERIAL
  end

  def height_expr(units) 
    properties.find_value(HEIGHT_DESCRIPTOR).map{|v| term(v.height(units))}.orSome(H)
  end

  def cost_expr(units, color, contexts)
    material_unit_cost = material(Panel::MATERIAL, color).cost_expr(term(1), term(1), units)
    area_expr = sum(mult(term(2), height_expr(units), sum(D, W)), mult(D, W))
    subtotal = mult(area_expr, material_unit_cost) 
    item_total = apply_margin(subtotal)

    super.map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end
