class AddCustomerServiceRole < ActiveRecord::Migration
  def self.up
    Role.create(:name => 'customer_service')
  end

  def self.down
    Role.find_by_name('customer_service').destroy
  end
end
