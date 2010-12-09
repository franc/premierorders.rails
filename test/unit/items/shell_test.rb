require 'test_helper'

class ShellTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Shell top panel pricing" do
    shell = Shell.find_by_name('shell')
    assert_not_nil shell

    price = shell.calculate_price(24, 48, 24 , 'white', :in)
    # cabinet shell has 24 sq. ft. of panel (4 + 4 + 8 + 8) and 0
    assert_equal((24  * 0.6) + (0.06 * (4 * 2 + 2 * 2)) , price)
  end
end

