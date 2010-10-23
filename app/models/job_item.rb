class JobItem < ActiveRecord::Base
	belongs_to :job
  belongs_to :item
	has_many :job_item_attributes

	def attr_value(name)
		item_attr = item.item_attributes.find_by_name(name)
		if item_attr
			job_attr = job_item_attributes.find_by_item_attribute_id(item_attr.id)
			job_attr.nil? ? item.default_attr_value(name) : item_attr.value_of(job_attr.value) || item.default_attr_value(name)
		else
			nil
		end
	end

	def method_missing(symbol, *args, &block)
		if (item.respond_to?(symbol))
			item.send(symbol, *args)
		else
			super(symbol, *args, &block)
		end
	end
end
