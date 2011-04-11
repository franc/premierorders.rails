require 'properties'
require 'fp'

class Items::ScaledItem < Item
  RANGED_PRICE  = Properties::PropertyDescriptor.new(:ranged_price, [], [Property::RangedValue])
  RANGED_WEIGHT = Properties::PropertyDescriptor.new(:ranged_weight, [], [Property::RangedValue])

  def self.required_properties
    [RANGED_PRICE]
  end

  def self.optional_properties
    super + [RANGED_WEIGHT]
  end

  def cost_expr(query_context)
    rps = properties.find_all_by_descriptor(RANGED_PRICE).map{|v| v.property_values}.flatten
    if rps.empty?
      super
    else
      rp_expr = sum(*rps.map{|v| v.expr(query_context.units)})
      super.map{|e| rp_expr + e}.orElse(Option.some(rp_expr))
    end
  end

  def weight_expr(query_context)
    rps = properties.find_all_by_descriptor(RANGED_WEIGHT).map{|v| v.property_values}.flatten
    if rps.empty?
      super
    else
      Option.append(sum(*rps.map{|v| v.expr(query_context.units)}), super, Semigroup::SUM)
    end
  end
end
