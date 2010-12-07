class PropertyValue < ActiveRecord::Base
  has_and_belongs_to_many :properties, :join_table => 'property_value_selection'

  def to_s
    "#{name}: #{value_str}"
  end
end
