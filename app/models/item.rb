class Item < ActiveRecord::Base
	has_and_belongs_to_many :attr_sets
  has_many :item_attrs, :through => :attr_sets

  has_many :item_components
  has_many :components, :through => :item_components, :class_name => 'Item'

  def compute_price(job_item)
    job_item.quantity * job_item.unit_price
  end
end