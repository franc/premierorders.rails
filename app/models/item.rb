require 'property.rb'

class Item < ActiveRecord::Base
  has_many :item_properties
	has_many :properties, :through => :item_properties, :extend => Properties::Association

  has_many :item_components
  has_many :components, :through => :item_components, :class_name => 'Item'

  def compute_price(job_item)
    job_item.quantity * job_item.unit_price
  end
end
