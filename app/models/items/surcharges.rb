require 'expressions'

module Items::Surcharges
  include Expressions
  SURCHARGE = PropertyDescriptor.new(:surcharge, [], [Property::Surcharge])
  RANGED_SURCHARGE = PropertyDescriptor.new(:ranged_surcharge, [], [Property::RangedValue])

  DESCRIPTORS = [SURCHARGE, RANGED_SURCHARGE]

  def surcharge_exprs(units)
    flat = properties.find_value(SURCHARGE).map{|v| term(v.price)}.to_a
    ranged = properties.find_value(RANGED_SURCHARGE).map{|v| v.expr(units)}.to_a

    flat + ranged
  end
end



