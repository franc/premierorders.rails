require 'properties'
require 'fp'

class Items::Panel < Item
  include Items::ItemMaterials

  MATERIAL = Properties::PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.required_properties
    [MATERIAL]
  end

  WIDTH  = Properties::PropertyDescriptor.new(:width, [], [Property::Width], 1)
  LENGTH = Properties::PropertyDescriptor.new(:length, [], [Property::Length], 1)

  def self.optional_properties
    super + [WIDTH, LENGTH]
  end

  def width 
    properties.find_value(WIDTH).map{|v| v.width}
  end

  def length
    properties.find_value(LENGTH).map{|v| v.length}
  end

  def material_descriptor
    MATERIAL
  end

  def cost_expr(query_context, l_expr = L, w_expr = W)
    material_cost = material(MATERIAL, query_context.color).cost_expr(
      length.map{|l| term(l)}.orSome(l_expr), 
      width.map{|w| term(w)}.orSome(w_expr), 
      query_context.units
    )

    item_total = apply_margin(material_cost)

    Option.append(item_total, super(query_context), Semigroup::SUM)
  end

  def weight_expr(query_context, l_expr = L, w_expr = W)
    material_weight = material(MATERIAL, query_context.color).weight_expr(
      length.map{|l| term(l)}.orSome(l_expr), 
      width.map{|w| term(w)}.orSome(w_expr), 
      query_context.units
    )

    Option.append(material_weight, super(query_context), Semigroup::SUM)
  end
end
