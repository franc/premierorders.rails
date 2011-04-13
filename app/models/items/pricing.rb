require 'expressions'

module Items::Pricing
  include Expressions
  LINEAR = Properties::PropertyDescriptor.new(:linear_pricing, [], [Property::LinearPricing])

  def linear_surcharge_expr(query_context, w_expr = W, h_expr = H, d_expr = D)
    #at present, this is just used to assign a linear surcharge to certain items.
    properties.find_value(LINEAR).map{|v| v.cost_expr(query_context.units, w_expr)}
  end
end


