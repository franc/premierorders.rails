class AddPurchasePartIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :purchase_part_id, :string
  end

  def self.down
    remove_column :items, :purchase_part_id
  end
end
