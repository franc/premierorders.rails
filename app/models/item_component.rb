require 'property.rb'

class ItemComponent < ActiveRecord::Base
  belongs_to :item
  belongs_to :component, :class_name => 'Item'

  has_many   :item_component_properties
  has_many   :properties, :through => :item_component_properties, :extend => Properties::Association

  def pricing_expr(units, color)
    component.pricing_expr(units, color)
  end
end

require 'items/shell_components.rb'
require 'items/cabinet_components.rb'
require 'items/corner_cabinet_components.rb'


