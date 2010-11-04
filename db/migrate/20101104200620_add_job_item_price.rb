class AddJobItemPrice < ActiveRecord::Migration
  def self.up
    add_column :job_items, :unit_price, :float
  end

  def self.down
    remove_column :job_items, :unit_price
  end
end
