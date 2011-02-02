require 'expressions'

module Items::Surcharges
  include Expressions
  SURCHARGE = PropertyDescriptor.new(:surcharge, [], [Property::Surcharge])
  RANGED_SURCHARGE = PropertyDescriptor.new(:ranged_surcharge, [], [Property::RangedValue])

  DESCRIPTORS = [SURCHARGE, RANGED_SURCHARGE]

  def surcharge_expr(units)
    flat = properties.find_value(SURCHARGE).map{|v| term(v.price)}
    ranged = properties.find_value(RANGED_SURCHARGE).map{|v| v.expr(units)}

    flat.map{|f| ranged.map{|r| sum(f, r)}.orSome(f)}.orElse(ranged)
  end

  def apply_surcharge(expr, units)
    surcharge_expr(units).map{|v| sum(expr, v)}.orSome(expr)
  end
end



