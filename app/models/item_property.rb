class ItemProperty < ActiveRecord::Base
  belongs_to :item
  belongs_to :property
end
