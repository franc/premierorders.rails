class AddPlacementToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :placement_date, :timestamp
    add_column :jobs, :placed_by_id, :int
    execute("ALTER TABLE jobs ADD FOREIGN KEY (placed_by_id) REFERENCES users")
  end

  def self.down
    remove_column :jobs, :placed_by_id
    remove_column :jobs, :placement_date
  end
end
