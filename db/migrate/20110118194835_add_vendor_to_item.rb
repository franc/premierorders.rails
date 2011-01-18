class AddVendorToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :vendor, :string
  end

  def self.down
    remove_column :items, :vendor
  end
end
