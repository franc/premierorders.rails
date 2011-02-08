class AddRebateFactorToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :rebate_factor, :float
    add_column :items, :retail_multiplier, :float
    execute "update items set rebate_factor = 0.92"
    execute "update items set retail_multiplier = 0.4"
  end

  def self.down
    remove_column :items, :rebate_factor
    remove_column :items, :retail_multiplier
  end
end
