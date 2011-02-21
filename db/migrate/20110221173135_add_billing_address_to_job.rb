class AddBillingAddressToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :billing_address_id, :integer
    execute("ALTER TABLE jobs ADD FOREIGN KEY (billing_address_id) REFERENCES addresses")
    execute("UPDATE franchisee_addresses SET address_type = 'billing' where address_type = 'Billing'")
    execute("UPDATE franchisee_addresses SET address_type = 'shipping' where address_type = 'Shipping'")
  end

  def self.down
    remove_column :jobs, :billing_address_id
  end
end
