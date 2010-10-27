# Values that the independent variable may take on
class ItemAttrOption < ActiveRecord::Base
	belongs_to :item
	belongs_to :item_attr

  def value
    item_attr.value(value_str)
  end
end