require 'test_helper'

class DoorTest < ActiveSupport::TestCase
  test "premium door pricing" do
  end

  test "french lite door pricing" do
    job = Job.find_by_job_number("ST01")
    item = Items::FrenchLiteDoor.find_by_name('French Lite Door')
    job_item = JobItem.create(
      :job => job,
      :item => item,
      :quantity => 2
    )

    job_item.job_item_properties.create(
      :family => 'french_door_divisions',
      :value_str => '{"value": 4}',
      :module_names => 'IntegerProperty'
    )

    job_item.job_item_properties.create(
      :family => 'dimensions',
      :value_str => '{"height": 48, "width": 24, "linear_units": "in"}',
      :module_names => 'Height, Width'
    )

    job_item.job_item_properties.create(
      :family => 'color',
      :value_str => '{"color": "Ruston Maple-DHRM"}',
      :module_names => 'Color'
    )

    #assert_equal((15.95 * 8) + (7.50 * 4) + 0.25, job_item.compute_unit_price)
  end
end
