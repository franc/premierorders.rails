require 'properties'
require 'expressions'

class ItemComponent < ActiveRecord::Base
  include Expressions

  belongs_to :item
  belongs_to :component, :class_name => 'Item'

  has_many   :item_component_properties, :dependent => :destroy
  has_many   :properties, :through => :item_component_properties, :extend => Properties::Association

  def self.component_modules(mod)
    types = []
    types += mod.component_types if mod.respond_to?(:component_types) 
    types
  end

  def contexts
    context_names.split(",").map{|s| s.strip}
  end

  def color_opts
    opts = self.respond_to?(:color_options) ? self.color_options : []
    component.nil? ? opts : component.color_opts + opts  
  end


  def component_ok?
    !component.nil? && component.components_ok? && component.properties_ok?
  end

  def component_errors
    component.component_errors.merge(component.property_errors) do |k, v1, v2|
      v1 + v2
    end
  end

  def properties_ok?
    Property.descriptors(self.class, :required).inject(true) do |result, desc|
      result && !properties.find_by_descriptor(desc).nil?
    end
  end

  def property_errors
    Property.descriptors(self.class, :required).inject({:absent => []}) do |result, desc|
      result[:absent] << desc if properties.find_by_descriptor(desc).nil? 
      result
    end
  end

  def query(item_query, contexts)
    item_query.traverse_item_component(self, contexts)
  end

  def qty_expr(query_context)
    term(quantity)
  end

  def cost_expr(query_context)
    component.cost_expr(query_context).map do |component_cost|
      qty_expr(query_context) * component_cost
    end
  end

  def weight_expr(query_context)
    component.weight_expr(query_context).map do |component_weight|
      qty_expr(query_context) * component_weight
    end
  end
end
