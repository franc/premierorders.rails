require 'property.rb'

class PropertyValue < ActiveRecord::Base
  include Properties::Polymorphic
  has_and_belongs_to_many :properties, :join_table => 'property_value_selection'
  after_find :morph

  def to_s
    "#{name}: #{value_str}"
  end
end
