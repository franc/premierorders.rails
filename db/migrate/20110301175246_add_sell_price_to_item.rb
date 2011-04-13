class AddSellPriceToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :sell_price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :items, :sell_price
  end
end
