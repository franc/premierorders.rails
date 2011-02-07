require 'json'

module ItemsHelper
  def component_select(mod, options = {})
    option_values = []
    Item.component_association_modules(mod).each_with_index{|c, i| option_values << [c.to_s.demodulize, i]}
    select_tag :component, options_for_select(option_values), options
  end

  def descriptors_json(mod)
  end

  def descriptor_select(mod, options = {}) 
    option_values = []
    Property.descriptors(mod).each_with_index{|d, i| option_values << [d.family.to_s.titlecase, i]}
    select_tag :descriptor, options_for_select(option_values), options
  end

  def property_value_field_tag(name, type, value = nil)
    if type.kind_of?(Array)
      select_tag(name, options_for_select(type.map{|t| [t, t]}, value), {:class => 'property_value_field'})
    else
      text_field_tag(name, value, {:class => 'property_value_field'})
    end
  end

  def property_qualifiers_select_tag(descriptor, options)
    select_tag :property_qualifiers, 
               options_for_select(descriptor.qualifiers.map{|q| [q, q]}), 
               options.merge({:multiple => 'true'})
  end

  def ok_tag(bool)
    bool ? %Q(<span style="color: green">ok</span>) : %Q(<span style="color: red">error</span>)
  end

  def next_item_path(item)
    items = item.previous_item
    items.empty? ? item_path(item) : item_path(items[0])
  end

  def previous_item_path(item)
    items = item.next_item
    items.empty? ? item_path(item) : item_path(items[0])
  end
end
