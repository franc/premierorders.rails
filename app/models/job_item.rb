class JobItem < ActiveRecord::Base
	belongs_to :job
  belongs_to :item, :include => :properties
	has_many   :job_item_properties, :extend => Properties::Association

  def compute_price
    (!item.nil? && item.respond_to?(:price_job_item)) ? item.price_job_item(self) : unit_price * quantity
  end
end
