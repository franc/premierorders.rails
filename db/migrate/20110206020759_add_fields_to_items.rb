class AddFieldsToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :weight, :float
    add_column :items, :install_cost, :float
  end

  def self.down
    remove_column :items, :install_cost
    remove_column :items, :weight
  end
end
