require 'properties'
require 'expressions'

module Items::Margins
  include Expressions

  MARGIN = Properties::PropertyDescriptor.new(:margin, [], [Property::Margin])

  def margin_factor
    properties.find_value(MARGIN).map{|f| f.factor}
  end

  def apply_margin(expr)
    margin_factor.map{|f| div(expr, term(f))}.orSome(expr)
  end
end



