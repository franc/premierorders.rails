class Item < ActiveRecord::Base
	has_and_belongs_to_many :item_attrs, :join_table => :items_item_attrs
  has_one :cutrite_refs
end

class CutriteRef < ActiveRecord::Base
  belongs_to :item
end