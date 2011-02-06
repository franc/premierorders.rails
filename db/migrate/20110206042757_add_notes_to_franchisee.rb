class AddNotesToFranchisee < ActiveRecord::Migration
  def self.up
    add_column :franchisees, :notes, :text
  end

  def self.down
    remove_column :franchisees, :notes
  end
end
