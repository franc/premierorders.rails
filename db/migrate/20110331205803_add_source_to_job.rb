class AddSourceToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :source, :string, :nullable => false, :default => 'dvinci'
  end

  def self.down
    remove_column :jobs, :source
  end
end
