class Item < ActiveRecord::Base
	has_and_belongs_to_many :properties
  has_many :property_values, :through => :properties

  has_many :item_components
  has_many :components, :through => :item_components, :class_name => 'Item'

  def compute_price(job_item)
    job_item.quantity * job_item.unit_price
  end
end