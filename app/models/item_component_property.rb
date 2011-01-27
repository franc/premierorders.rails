class ItemComponentProperty < ActiveRecord::Base
  belongs_to :item_component
  belongs_to :property
end
