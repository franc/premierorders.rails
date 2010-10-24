# Independent variables that may be associated with an item
class Attribute < ActiveRecord::Base
  belongs_to :item
	has_many :attribute_options

	def default_value
		v = attribute_options.find_by_default(true)
		v.nil? ? nil : v.value
	end

  def value(value_str)
		if (value_str.nil?)
			nil
		else
			case (value_type.to_sym)
        when :string then value_str
        when :int    then value_str.to_i
        when :float  then value_str.to_f
			end
		end
	end
end

# Values that the independent variable may take on
class AttributeOption < ActiveRecord::Base
	belongs_to :attribute

  def value
    attribute.value(value_str)
  end
end
