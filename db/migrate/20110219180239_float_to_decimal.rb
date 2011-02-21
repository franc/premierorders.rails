class FloatToDecimal < ActiveRecord::Migration
  def self.up
    change_column :franchisees, :margin_cabinets, :decimal, :precision => 8, :scale => 2
    rename_column :franchisees, :margin_accessoried, :margin_accessories
    change_column :franchisees, :margin_accessories, :decimal, :precision => 8, :scale => 2
    change_column :franchisees, :margin_flooring, :decimal, :precision => 8, :scale => 2
    change_column :franchisees, :variance_min, :decimal, :precision => 8, :scale => 2
    change_column :franchisees, :variance_max, :decimal, :precision => 8, :scale => 2

    change_column :items, :base_price, :decimal, :precision => 8, :scale => 2
    change_column :items, :install_cost, :decimal, :precision => 8, :scale => 2
    
    change_column :job_items, :unit_price, :decimal, :precision => 8, :scale => 2
    change_column :job_items, :override_price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
  end
end
