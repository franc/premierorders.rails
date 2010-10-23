class Item < ActiveRecord::Base
	has_many :ivars

	def ivar_default_value(name)
		variable = ivars.find_by_name(name)
		value = variable.ivar_values.find_by_default(true) || variable.ivar_values.first

		if value.nil?
			nil
		else
			variable.nil? ? value.value : variable.value_of(value.value)
		end
	end
end
