# Independent variables that may be associated with an item
class ItemAttr < ActiveRecord::Base
  has_and_belongs_to_many :items, :join_table => :items_item_attrs
	has_many :attribute_options

	def default_value
		v = attribute_options.find_by_default(true)
		v.nil? ? nil : v.value
	end

  def value(value_str)
		if (value_str.nil?)
			nil
		else
			case (self.value_type.to_sym)
        when :string then value_str
        when :int    then value_str.to_i
        when :float  then value_str.to_f
			end
		end
	end
end

# Values that the independent variable may take on
class AttributeOption < ActiveRecord::Base
	belongs_to :item_attr

  def value
    item_attr.value(value_str)
  end
end
