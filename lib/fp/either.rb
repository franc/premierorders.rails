require 'fp/option'

module Either
  def self.left(v)
    Left.new(v)    
  end

  def self.right(v)
    Right.new(v)    
  end

  def right
    RightProjection.new(self)
  end

  def left 
    LeftProjection.new(self)
  end

  def value
    cata(Function::IDENTITY, Function::IDENTITY)
  end
end

class Left 
  include Either

  def initialize(v)
    @value = v
  end

  def cata(left, right)
    left.call(@value)
  end
end

class Right 
  include Either

  def initialize(v)
    @value = v
  end

  def cata(left, right)
    right.call(@value)
  end
end

class LeftProjection 
  include Enumerable

  attr_reader :either

  def initialize(e)
    @either = e
  end

  def map(&f)
    @either.cata(lambda{|v| Left.new(f.call(v))}, Functions.const(@either))
  end

  def bind(&f)
    @either.cata(lambda{|v| f.call(v)}, Functions.const(@either))
  end

  def orElse(default)
    @either.cata(Functions::IDENTITY, Functions.const(default))
  end

  def toOption
    @either.cata(lambda{|v| Option.some(v)}, Functions.const(Option.none))
  end

  alias_method :each, :map
end

class RightProjection 
  include Enumerable

  attr_reader :either

  def initialize(e)
    @either = e
  end

  def map(&f)
    @either.cata(Functions.const(@either), lambda{|v| Right.new(f.call(v))})
  end

  def bind(&f)
    @either.cata(Functions.const(@either), lambda{|v| f.call(v)})
  end

  def orElse(default)
    @either.cata(Functions.const(default), Functions::IDENTITY)
  end

  def toOption
    @either.cata(Functions.const(Option.none), lambda{|v| Option.some(v)})
  end

  alias_method :each, :map
end
