require 'json'

module ItemsHelper
  def self.descriptors(value)
    descriptors = []
    descriptors += value.class.required_properties if (value.class.respond_to?(:required_properties))
    descriptors += value.class.optional_properties if (value.class.respond_to?(:optional_properties))
    descriptors
  end

  def self.descriptors_json(value)
    descriptors(value).to_json
  end

  def self.descriptor_select(value, options = {}) 
    option_values = []
    descriptors(value).each_with_index{|d, i| option_values << [d.family.titlecase, i]}
    select_tag :descriptor, option_values, options
  end

  def self.property_value_field_tag(name, type)
    if type.kind_of?(Array)
      select_tag name, options_for_select(type.map{|t| [t, t]}), :class => 'property_value_field'
    else
      text_field_tag name, :class => 'property_value_field'
    end
  end

  def self.property_qualifiers_select_tag(descriptor, options)
    select_tag :property_qualifiers, 
               options_for_select(descriptor.qualifiers.map{|q| [q, q]}), 
               options.merge({:multiple => 'true'})
  end
end
