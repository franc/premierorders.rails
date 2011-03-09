require 'properties/named_modules'
require 'properties/modular_property'

module Properties
  module Polymorphic
    include NamedModules, ModularProperty

    def morph
      modules.each {|mod| self.extend(mod) unless self.kind_of?(mod)}
    end
  end
end

