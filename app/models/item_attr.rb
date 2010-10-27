# Independent variables that may be associated with an item
class ItemAttr < ActiveRecord::Base
	has_many :item_attr_options

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