class AddShipByToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :ship_by, :string, :default => 'standard'
  end

  def self.down
    remove_column :items, :ship_by
  end
end
