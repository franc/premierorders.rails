require 'json'
require 'property.rb'

module ModularProperty
  def value_structure
    modules.inject({}) {|vs, mod| vs.merge(mod.value_structure)}  
  end
end

module NamedModules
  def modules
    (module_names || '').split(/\s*,\s*/).map do |mod_name|
      Property.const_get(mod_name.demodulize.to_sym)
    end
  end
end

module Properties
  module Polymorphic
    include NamedModules, ModularProperty

    def morph
      modules.each {|mod| self.extend(mod) unless self.kind_of?(mod)}
    end
  end

  module Association
    def find_by_family_with_qualifier(family, qualifier)
      find(:all, :conditions => ['family = ? and qualifier = ?', family, qualifier])
    end

    def find_by_descriptor(descriptor)
      conditions = descriptor.qualifiers.empty? ? ['family = ?', descriptor.family] : ['family = ? and qualifier in (?)', descriptor.family, descriptor.qualifiers]
      find(:first, :conditions => conditions)
    end
  end

  module JSONProperty
    def extract(json_property = nil, type = nil)
      @value_hash ||= JSON.parse(value_str)
      if json_property
        string_value = @value_hash[json_property.to_s]
        case type
          when :int   then string_value.to_i
          when :float then string_value.to_f
          else string_value
        end
      else
        @value_hash
      end
    end
  end

  module LinearConversions
    UNITS = [:mm, :in, :ft]

    def convert(value, from, to)
      case from.to_sym
      when :mm
        case to.to_sym
        when :mm then value
        when :in then value / 25.4
        when :ft then (value / 25.4) / 12
        end
      when :in
        case to.to_sym
        when :in then value
        when :mm then value * 25.4
        when :ft then value / 12
        end
      when :ft
        case to.to_sym
        when :in then value * 12
        when :mm then value * 12 * 25.4
        when :ft then value
        end
      end
    end
  end

  module Dimensions
    include Properties::JSONProperty, Properties::LinearConversions

    def dimension_value(property, in_units, out_units)
      convert(extract(property).to_f, in_units, out_units)
    end
  end
end


