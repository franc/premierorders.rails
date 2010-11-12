class AddStatusToJob < ActiveRecord::Migration
  def self.up
    execute "CREATE TYPE status_type AS ENUM ('Created', 'In Review', 'Confirmed', 'On Hold', 'Ready For Production', 'In Production', 'Ready to Ship', 'Hold Shipment', 'Shipped', 'Cancelled');"
    add_column :jobs, :status, 'status_type'
  end

  def self.down
    remove_column :jobs, :status
    execute "DROP TYPE status_type";
  end
end
