class AddStatusToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :status, :string
  end

  def self.down
    remove_column :jobs, :status
  end
end
