require 'property.rb'

class PropertyValue < ActiveRecord::Base
  include Properties::Polymorphic, Properties::JSONProperty
  has_and_belongs_to_many :properties, :join_table => 'property_value_selection'
  after_find :morph

  def field_values
    values = extract()
    result = {}
    value_structure.each do |name, type|
      result[name] = {:type => type, :value => values[name.to_s]}
    end
    result
  end

  def to_s
    "#{name}: #{value_str}"
  end
end
