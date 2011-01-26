class AddTrackingToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :tracking_number, :string
    add_column :job_items, :override_price, :float
  end

  def self.down
    remove_column :jobs, :tracking_number
    remove_column :job_items, :override_price
  end
end
