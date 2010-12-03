class AddItemPurchasing < ActiveRecord::Migration
  def self.up
    add_column :items, :purchasing, :string
  end

  def self.down
    remove_column :items, :purchasing
  end
end
