module Option
  def self.new(value)
    value.nil? ? None::NONE : Some.new(value)
  end

  def self.some(value)
    Some.new(value)
  end

  def self.none
    None::NONE
  end

  def self.iif(bool, value)
    bool ? None::NONE : Option.new(value)
  end

  def self.fromString(value)
    value.nil? ? None::NONE : (value.strip.empty? ? None::NONE : Some.new(value))
  end

  def map(&f)
    cata(lambda {|a| Some.new(f.call(a))}, None::NONE)
  end

  # This is like map, except that null values returned from the applied
  # function result in equivalent behavior to calling bind(_ => None::NONE)
  def mapn(&f)
    cata(lambda {|a| Option.new(f.call(a))}, None::NONE)
  end

  def bind(&f)
    cata(f, None::NONE)
  end

  def empty?
    cata(lambda {|a| false}, true)
  end

  alias_method :each, :map
end

class Some
  include Option
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def cata(f, default)
    f.call(@value)
  end

  def orSome(default)
    @value
  end

  def orLazy(&f)
    @value
  end

  def orElse(opt)
    self
  end

  def inspect
    "Some(#{@value.inspect})"
  end

  def to_s
    @value.to_s
  end
end

class None
  include Option

  NONE = None.new

  def cata(f, default)
    default
  end

  def orSome(default)
    default
  end

  def orLazy(&f)
    f.call
  end

  def orElse(opt)
    opt
  end

  def inspect
    "None"
  end

  alias_method :to_s, :inspect
end

