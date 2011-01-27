class AddShipMethodToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :ship_method, :string
  end

  def self.down
    remove_column :jobs, :ship_method
  end
end
