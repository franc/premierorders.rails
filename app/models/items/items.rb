module Items
  module Margins
    include Expressions
    MARGIN = PropertyDescriptor.new(:margin, [], [Property::Margin])

    def margin_factor
      properties.find_value(MARGIN)
    end

    def apply_margin(expr)
      margin_factor.map{|f| div(expr, term(f.factor))}.orSome(expr)
    end
  end
end



