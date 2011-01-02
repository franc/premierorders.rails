class AddBasePriceToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :base_price, :float
  end

  def self.down
    remove_column :items, :base_price
  end
end
