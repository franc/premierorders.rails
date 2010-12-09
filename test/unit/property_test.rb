require 'test_helper'

class PropertyTest < ActiveSupport::TestCase
  test "properties must propagate their modules to values of their type" do
    property = Property.find_by_name("Panel Material")
    property_value = property.property_values.find_by_name('1/2" White Melamine')
    property.hydrate(property_value)
    assert_not_nil(property_value, "No such material found")
    assert_equal(property_value.color, "white")
    assert_equal(property_value.thickness(:in), 0.5)
  end
end

class LinearConversionsTest < ActiveSupport::TestCase
  include Properties::LinearConversions
  test "linear conversions return the correct result" do
    assert_equal(50.8, convert(2, :in, :mm))
    assert_equal(2, convert(50.8, :mm, :in))
    assert_equal(2, convert(2, :mm, :mm))
    assert_equal(2, convert(2, :in, :in))
  end
end
