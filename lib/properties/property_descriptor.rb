require 'properties/modular_property'

module Properties
  class PropertyDescriptor
    include ModularProperty
    attr_reader :family, :qualifiers, :modules, :value_arity

    def initialize(family, qualifiers, modules, value_arity = nil, options = nil)
      @family = family
      @qualifiers = qualifiers
      @modules = modules
      @value_arity = value_arity
      @options = options # a list of lambdas that can extract value options from an item or item_component
    end

    def options(item)
      @options.nil? ? [] : @options.call(item)
    end

    def module_names
      modules.map{|m| m.to_s.demodulize}.join(", ")
    end

    def create_property(name)
      Property.create(
        :name => name,
        :family => family,
        :module_names => module_names
      )
    end

    def <=>(other)
      family.to_s <=> other.family.to_s 
    end
  end
end
