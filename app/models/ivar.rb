# Independent variables that may be associated with an item
class IVar < ActiveRecord::Base
	has_many :ivar_values

	def value_of(data)
		if (data.nil?)
			nil
		else
			case (value_type.to_sym)
			when :string then data.to_s
			when :int    then data.to_i
			when :float  then data.to_f
			end
		end
	end
end

# Values that the independent variable may take on
class IVarValue < ActiveRecord::Base
	belongs_to :ivar
end
