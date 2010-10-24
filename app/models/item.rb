class Item < ActiveRecord::Base
	has_and_belongs_to_many :attributes
  has_one :cutrite_refs
end

class CutriteRef < ActiveRecord::Base
  belongs_to :item
end