class Item < ActiveRecord::Base
  has_many :item_attr_options
	has_many :item_attrs, :through => :item_attr_options, :uniq => true
end