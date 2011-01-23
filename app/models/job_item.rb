class JobItem < ActiveRecord::Base
	belongs_to :job
  belongs_to :item
	has_many   :job_item_properties, :dependent => :destroy, :extend => Properties::Association

  def compute_unit_price
    logger.info("Computing price for #{item.inspect}: #{item.respond_to?(:price_job_item)}")
    ((!item.nil?) && item.respond_to?(:price_job_item)) ? item.price_job_item(self) : unit_price
  end

  def compute_total
    compute_unit_price * quantity
  end
end
