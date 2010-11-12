class AddDatesToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :due_date, :date
    add_column :jobs, :ship_date, :date
  end

  def self.down
    remove_column :jobs, :ship_date
    remove_column :jobs, :due_date
  end
end
