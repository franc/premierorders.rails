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

    def self.fromString(value)
      value.nil? ? None::NONE : (value.strip.empty? ? None::NONE : Some.new(value))
    end

    def map(&f)
      cata(lambda {|a| Some.new(f.call(a))}, None::NONE)
    end

    def bind(&f)
      cata(f, None::NONE)
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
  end

  class None
    include Option

    NONE = None.new

    def cata(f, default)
      default
    end
  end

