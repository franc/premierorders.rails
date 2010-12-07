class JobItem < ActiveRecord::Base
	belongs_to :job
  belongs_to :item, :include => :properties
	has_many   :job_item_properties

  def compute_price
    item.nil? ? (unit_price * quantity) : item.compute_price(this)
  end

	def property(name)
    property = item.nil? ? nil : item.properties.find_by_name(name)
    if property
      job_item_properties.find_by_property_id(property.id)
    else
      job_item_properties.find_by_ingest_id(name)
    end
	end
end
