class JobItem < ActiveRecord::Base
	belongs_to :job
  belongs_to :item
	has_many :job_item_attributes

	def item_attr(name)
    attr = item.nil? ? nil : item.item_attrs.find_by_name(name)
    if attr
      job_attr = job_item_attributes.find_by_item_attr_id(attr.id)
      job_attr.nil? ? attr.default_value : attr.value(job_attr.value_str)
    else
      job_attr = job_item_attributes.find_by_ingest_id(name)
      job_attr.nil? ? nil : job_attr.value_str
    end
	end
end

class JobItemAttribute < ActiveRecord::Base
  belongs_to :job_item
  belongs_to :item_attribute
end
