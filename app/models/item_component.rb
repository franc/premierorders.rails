require 'property.rb'

class ItemComponent < ActiveRecord::Base
  belongs_to :item
  belongs_to :component, :class_name => 'Item'

  has_many   :item_component_properties
  has_many   :properties, :through => :item_component_properties, :extend => Properties::Association

  def pricing_expr(units, color)
    component.pricing_expr(units, color)
  end

  def color_opts
    opts = self.respond_to?(:color_options) ? self.color_options : []
    component.color_opts + opts  
  end

  def component_ok?
    component.components_ok? && component.properties_ok?
  end

  def component_errors
  end

  def properties_ok?
    Property.descriptors(self.class, :required).inject(true) do |result, desc|
      result && !properties.find_by_descriptor(desc).nil?
    end
  end

  def property_errors
  end
end

require 'items/shell_components.rb'
require 'items/cabinet_components.rb'
require 'items/corner_cabinet_components.rb'


