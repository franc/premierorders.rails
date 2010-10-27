require 'test_helper'

class JobTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "xml import" do
    franchisee = Franchisee.find(:all)[0]
    address = Address.find(:all)[0]
    job = Job.create(:franchisee => franchisee, :name => "Test", :job_number => "AB-123", :shipping_address => address)
    File.open("#{File.dirname(__FILE__)}/test_data/dvinci_test.xml") do |xml|
      job.add_items_from_dvinci(xml)
    end
  end
end
