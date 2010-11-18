class AddCommentToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :comment, :text
  end

  def self.down
    remove_column :jobs, :comment
  end
end
