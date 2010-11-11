class AddItemPurchasing < ActiveRecord::Migration
  def self.up
    execute "CREATE TYPE purchase_type AS ENUM ('Manufactured', 'Inventory', 'Purchased');"
    add_column :items, :purchasing, 'purchase_type'
  end

  def self.down
    remove_column :items, :purchasing
    execute "DROP TYPE purchase_type;"
  end
end
