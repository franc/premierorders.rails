class AddTypeToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :type, :string, :default => 'Job'
  end

  def self.down
    remove_column :jobs, :type
  end
end
