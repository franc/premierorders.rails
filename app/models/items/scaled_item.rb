require 'properties'
require 'fp'

class Items::ScaledItem < Item
  RANGED_PRICE = Properties::PropertyDescriptor.new(:ranged_price, [], [Property::RangedValue])

  def self.required_properties
    [RANGED_PRICE]
  end

  def cost_expr(units, color, contexts)
    rps = properties.find_all_by_descriptor(RANGED_PRICE).map{|v| v.property_values}.flatten
    if rps.empty?
      super
    else
      rp_expr = sum(*rps.map{|v| v.expr(units)})
      super.map{|e| sum(rp_expr, e)}.orElse(Option.some(rp_expr))
    end
  end
end
