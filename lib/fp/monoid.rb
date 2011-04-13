require 'fp/option'

module Monoid
  class Sum
    attr_reader :zero
    def initialize(zero)
      @zero = zero
    end

    def append(o1, o2)
      o1 + o2
    end
  end

  class Uniq
    def initialize(&eq)
      @eq = eq || lambda {|v1, v2| v1 == v2}
    end

    def zero
      Option.none
    end

    def append(o1, o2)
      raise "Found conflicting values: #{o1.inspect} vs #{o2.inspect}" if o1.any?{|v1| o2.any?{|v2| !@eq.call(v1, v2)}}
      o1.orElse(o2)    
    end
  end

  class Pref
    def initialize(&choice)
      @choice = choice
    end

    def zero
      Option.none
    end

    def append(o1, o2)
      o1.map{|v1| o2.map{|v2| @choice.call(v1, v2)}.orSome(v1)}.orElse(o2)
    end
  end

  class OptionM
    def initialize(value_semigroup)
      @value_semigroup = value_semigroup
    end

    def zero
      Option.none
    end

    def append(o1, o2)
      o1.map{|v1| o2.map{|v2| @value_semigroup.append(v1, v2)}.orSome(v1)}.orElse(o2)
    end
  end

  UNIQ = Uniq.new
  ARRAY_APPEND = Sum.new([])
  INT_SUM = Sum.new(0)
  FLOAT_SUM = Sum.new(0.0)
end
