require 'test_helper'

class PropertyTest < ActiveSupport::TestCase
  test "properties must propagate their modules to values of their type" do
    property = Property.find_by_name("Panel Materials")
    property_value = property.property_values.find_by_name('1/2" White Melamine')
    property.hydrate(property_value)
    assert_not_nil(property_value, "No such material found")
    assert_equal(property_value.color, "white")
    assert_equal(property_value.thickness(:in), 0.5)
  end
end
