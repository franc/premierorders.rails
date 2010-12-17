require 'property.rb'

class ItemComponent < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  belongs_to :component, :class_name => 'Item', :polymorphic => true

  has_many   :item_component_properties
  has_many   :properties, :through => :item_component_properties, :extend => Properties::Association
end
