require 'bigdecimal'
require 'fp'

module Expressions
  class Expr
    include Expressions

    def +(other)
      sum(self, other)
    end

    def -(other)
      sub(self, other)
    end

    def *(other)
      mult(self, other)
    end

    def /(other)
      div(self, other)
    end

    def reduce(values, &block)
      values.inject(Option.none) do |t, v| 
        t.map{|ct| block.call(ct, v)}.orElse(Option.some(v))
      end
    end

    def evaluate(vars)
      begin
        expr_eval(vars)  
      rescue
        raise $!, "Error evaluating #{self} at #{vars.inspect}: #{$!.message}", $!.backtrace
      end
    end

    def inspect
      compile
    end

    alias_method :to_s, :inspect
  end

  class Sum < Expr
    attr_reader :exprs

    def initialize(*exprs)
      @exprs = exprs
    end  

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        Sum.new(*(@exprs.inject([]){|m, e| m << e.replace(expr, replacement)}))
      end
    end

    def compile
      @exprs.length > 1 ? "(#{@exprs.map{|e| e.compile}.join(" + ")})" : @exprs[0].compile
    end

    def expr_eval(vars)
      reduce(@exprs.map{|e| e.evaluate(vars)}){|m, v| m + v}.some
    end

    def eql?(other)
      other.kind_of?(Sum) && other.exprs.eql?(@exprs)
    end

    alias_method :==, :eql?
  end

  class Mult < Expr
    def initialize(*exprs)
      @exprs = exprs
    end  

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        Mult.new(*(@exprs.inject([]){|m, e| m << e.replace(expr, replacement)}))
      end
    end

    def compile
      @exprs.length > 1 ? "(#{@exprs.map{|e| e.compile}.join(" * ")})" : @exprs[0].compile
    end

    def expr_eval(vars)
      reduce(@exprs.map{|e| e.evaluate(vars)}){|m, v| m * v}.some
    end

    def eql?(other)
      other.kind_of?(Mult) && other.exprs.eql?(@exprs)
    end

    alias_method :==, :eql?
  end

  class Div < Expr
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

    def expr_eval(vars)
      @numerator.evaluate(vars) / @denominator.evaluate(vars)
    end

    def eql?(other)
      other.kind_of?(Div) && @numerator.eql?(other.numerator) && @denominator.eql?(other.denominator)
    end

    alias_method :==, :eql?
  end

  class Sub < Expr
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

    def expr_eval(vars)
      @minuend.evaluate(vars) / @subtrahend.evaluate(vars)
    end

    def eql?(other)
      other.kind_of?(Sub) && @minuend.eql?(other.minuend) && @subtrahend.eql?(other.subtrahend)
    end

    alias_method :==, :eql?
  end

  class Term < Expr
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
      expr_eval(nil).to_s
    end

    def expr_eval(vars)
      begin
        @value.round(11)
      rescue
        @value
      end
    end

    def eql?(other)
      other.kind_of?(Term) && @value.eql?(other.value)
    end

    alias_method :==, :eql?
  end

  class Var < Expr
    attr_reader :var
    def initialize(var)
      @var = var
    end

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        self
      end
    end

    def compile
      @var.to_s
    end

    def expr_eval(vars)
      vars[self]
    end

    def eql?(other)
      other.kind_of?(Var) && @var.eql?(other.var)
    end

    alias_method :==, :eql?
  end

  class Ranged < Expr
    include Expressions
    attr_reader :var, :min, :max, :result
    def initialize(var, min, max, result)
      @var = var
      @min = min
      @max = max
      @result = result
    end

    def replace(expr, replacement)
      if self.eql?(expr)
        replacement
      else
        Ranged.new(
          @var.replace(expr, replacement),
          @min.nil? ? nil : @min.replace(expr, replacement),
          @max.nil? ? nil : @max.replace(expr, replacement),
          @result.replace(expr, replacement)
        )
      end
    end

    def compile
      if min.nil?
        mult(term("(#{@var.compile} <= #{@max.compile} ? 1 : 0)"), @result).compile
      elsif max.nil?
        mult(term("(#{@var.compile} > #{@min.compile} ? 1 : 0)"), @result).compile
      else
        mult(term("(#{@var.compile} > #{@min.compile} && #{@var.compile} <= #{@max.compile} ? 1 : 0)"), @result).compile
      end
    end

    def expr_eval(vars)
      if min.nil?
        @var.evaluate(vars) <= @max.evaluate(vars) ? @result.evaluate(vars) : vars[ZERO]
      elsif max.nil?
        @var.evaluate(vars) > @min.evaluate(vars) ? @result.evaluate(vars) : vars[ZERO]
      else
        value = @var.evaluate(vars)
        value > @min.evaluate(vars) && value <= @max.evaluate(vars) ? @result.evaluate(vars) : vars[ZERO]
      end
    end

    def eql?(other)
      other.kind_of(Ranged) &&
      @var.eql?(other.var) &&
      @min.eql?(other.min) &&
      @max.eql?(other.max) &&
      @result.eql?(other.result) 
    end

    alias_method :==, :eql?
  end

  def sum(*exprs)
    Sum.new(*exprs)
  end

  def mult(*exprs)
    Mult.new(*exprs)
  end

  def div(num, den)
    Div.new(num, den)
  end

  def sub(min, sub)
    Sub.new(min, sub)
  end

  def ranged(var, min, max, result)
    Ranged.new(var, min, max, result)
  end

  def term(value)
    Term.new(value)
  end

  W = Var.new('W')
  D = Var.new('D')
  H = Var.new('H')
  L = Var.new('L')
  ZERO = Var.new('0')
end
