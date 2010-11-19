class AddTrackingIdToJobItem < ActiveRecord::Migration
  def self.up
    add_column :job_items, :tracking_id, :int
  end

  def self.down
    remove_column :job_items, :tracking_id
  end
end
