class ItemComponent < ActiveRecord::Base
  belongs_to :item
  belongs_to :component, :class_name => 'Item'
end