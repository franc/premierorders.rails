require 'test_helper'

class ShellTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "shell pricing" do
    shell = Items::Shell.find_by_name('shell')
    assert_not_nil shell

    # price = shell.calculate_price(24, 48, 24 , 'white', :in)
    # cabinet shell has 24 sq. ft. of panel (top: 4 + bottom: 4 + side: 8 + side: 8) 
    # cabinet shell has 12 ft. of horiz. edge banding & 8 feet of vertical
    # assert_in_delta((24  * 0.6) + (0.06 * 20) , price, 0.001)
  end
end

