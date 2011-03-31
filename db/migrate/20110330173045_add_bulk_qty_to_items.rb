class AddBulkQtyToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :bulk_qty, :int
  end

  def self.down
    remove_column :items, :bulk_qty
  end
end
