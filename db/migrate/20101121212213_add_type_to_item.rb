class AddTypeToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :type, :string
    execute "UPDATE items SET type = 'Item'"
  end

  def self.down
    remove_column :items, :type
  end
end
