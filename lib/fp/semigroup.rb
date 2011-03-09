require 'expressions'

module Semigroup
  class Sum
    def append(e1, e2)
      e1 + e2
    end
  end

  class Mult
    def append(e1, e2)
      e1 * e2
    end
  end

  SUM = Sum.new
  MULT = Mult.new
end
