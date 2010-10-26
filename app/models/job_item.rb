class JobItem < ActiveRecord::Base
	belongs_to :job
  belongs_to :item
	has_many :job_item_attributes

	def [](name)
		attr = item.attributes.find_by_name(name)
		if attr
			job_attr = job_item_attributes.find_by_attribute_id(attr.id)
			job_attr.nil? ? attr.default_value : attr.value(job_attr.value_str)
		else
			job_attr = job_item_attributes.find_by_ingest_key(name)
      job_attr.nil? ? nil : job_attr.value_str
		end
	end

	#def method_missing(symbol, *args)
	#	if (item.respond_to?(symbol))
	#		item.send(symbol, *args)
	#	else
	#		super(symbol, *args)
	#	end
	#end
end

class JobItemAttribute < ActiveRecord::Base
  belongs_to :job_item
  belongs_to :ivar
end
