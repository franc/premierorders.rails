# Independent variables that may be associated with an item
class ItemAttr < ActiveRecord::Base
	has_many :item_attr_options

  def default_value
    option = self.item_attr_options.find_by_default(true)
    option.nil? ? nil : value(option.value_str)
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