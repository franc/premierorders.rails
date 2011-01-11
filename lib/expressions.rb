module Expressions
  class Sum
    attr_reader :exprs

    def initialize(*exprs)
      @exprs = exprs
    end  

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        exprs = @exprs.inject([]){|m, e| m << e.replace(expr, replacement)}
        Sum.new(exprs)
      end
    end

    def compile
      "(#{@exprs.map{|e| e.compile}.join(" + ")})"
    end

    def eql?(other)
      other.kind_of?(Sum) && other.exprs.eql?(@exprs)
    end

    alias_method :==, :eql?
  end

  class Mult
    include Eq
    def initialize(*exprs)
      @exprs = exprs
    end  

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        exprs = @exprs.inject([]){|m, e| m << e.replace(expr, replacement)}
        Mult.new(exprs)
      end
    end

    def compile
      "(#{@exprs.map{|e| e.compile}.join(" * ")})"
    end

    def eql?(other)
      other.kind_of?(Mult) && other.exprs.eql?(@exprs)
    end

    alias_method :==, :eql?
  end

  class Div
    attr_reader :numerator, :denominator
    def initialize(numerator, denominator)
      @numerator = numerator
      @denominator = denominator
    end

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        Div.new(@numerator.replace(expr, replacement), @denominator.replace(expr, replacement))
      end
    end

    def compile
      "(#{@numerator.compile} / #{@denominator.compile})"
    end

    def eql?(other)
      other.kind_of?(Div) && @numerator.eql?(other.numerator) && @denominator.eql?(other.denominator)
    end

    alias_method :==, :eql?
  end

  class Sub
    attr_reader :minuend, :subtrahend
    def initialize(minuend, subtrahend)
      @minuend = minuend
      @subtrahend = subtrahend
    end

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        Sub.new(@minuend.replace(expr, replacement), @subtrahend.replace(expr, replacement))
      end
    end

    def compile
      "(#{@minuend.compile} - #{@subtrahend.compile})"
    end

    def eql?(other)
      other.kind_of?(Sub) && @minuend.eql?(other.minuend) && @subtrahend.eql?(other.subtrahend)
    end

    alias_method :==, :eql?
  end

  class Term
    attr_reader :value
    def initialize(value)
      @value = value
    end

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        self
      end
    end

    def compile
      @value.to_s
    end

    def eql?(other)
      other.kind_of?(Term) && @value.eql?(other.value)
    end

    alias_method :==, :eql?
  end

  def sum(exprs)
    Sum.new(exprs)
  end

  def mult(exprs)
    Mult.new(exprs)
  end

  def div(num, den)
    Div.new(num, den)
  end

  def sub(min, sub)
    Sub.new(min, sub)
  end

  def term(value)
    Term.new(value)
  end

  W = Term.new('W')
  D = Term.new('D')
  H = Term.new('H')
  L = Term.new('L')
end
