require 'expressions'
require 'util/option'

module Items::Pricing
  include Expressions
  LINEAR = PropertyDescriptor.new(:linear_pricing, [], [Property::LinearPricing])

  def property_pricing_expr(units, w_expr = W, h_expr = H, d_expr = D)
    properties.find_value(LINEAR).map{|v| v.cost_expr(units, w_expr)}
  end
end


