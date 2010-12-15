require 'json'

module ItemsHelper
  def component_types(mod)
    types = []
    types += mod.component_types if mod.respond_to?(:component_types)
    types
  end

  def component_association_types(mod)
    types = []
    types += mod.component_association_types if mod.respond_to?(:component_association_types)
    types
  end

  def component_types_json(mod)
    type_map = component_association_types(mod).inject([]) do |result, cmod|
      result << { 
        :association_type => cmod.to_s.demodulize,
        :component_types  => component_types(cmod).map{|ct| ct.to_s.demodulize} 
      }
    end
    type_map.to_json
  end

  def component_select(mod, options = {})
    option_values = []
    component_association_types(mod).each_with_index{|c, i| option_values << [c.to_s.demodulize, i]}
    select_tag :component, options_for_select(option_values), options
  end

  def descriptors(mod)
    descriptors = []
    descriptors += mod.required_properties if (mod.respond_to?(:required_properties))
    descriptors += mod.optional_properties if (mod.respond_to?(:optional_properties))
    descriptors
  end

  def descriptors_json(mod)
    descriptors(mod).to_json
  end

  def descriptor_select(mod, options = {}) 
    option_values = []
    descriptors(mod).each_with_index{|d, i| option_values << [d.family.titlecase, i]}
    select_tag :descriptor, options_for_select(option_values), options
  end

  def property_value_field_tag(name, type)
    if type.kind_of?(Array)
      select_tag name, options_for_select(type.map{|t| [t, t]}), :class => 'property_value_field'
    else
      text_field_tag name, :class => 'property_value_field'
    end
  end

  def property_qualifiers_select_tag(descriptor, options)
    select_tag :property_qualifiers, 
               options_for_select(descriptor.qualifiers.map{|q| [q, q]}), 
               options.merge({:multiple => 'true'})
  end
end
