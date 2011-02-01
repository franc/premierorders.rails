require 'expressions'

module Items::Surcharges
  include Expressions
  SURCHARGE = PropertyDescriptor.new(:surcharge, [], [Property::Surcharge])

  def surcharge
    properties.find_value(SURCHARGE).map{|v| v.price}
  end

  def apply_surcharge(expr)
    surcharge.map{|v| sum(expr, term(v))}.orSome(expr)
  end
end



