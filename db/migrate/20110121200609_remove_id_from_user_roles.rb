class RemoveIdFromUserRoles < ActiveRecord::Migration
  def self.up
    remove_column :user_roles, :id
    remove_column :user_roles, :created_at
    remove_column :user_roles, :updated_at
  end

  def self.down
    add_column :user_roles, :id, :int
    add_column :user_roles, :created_at, :timestamp
    add_column :user_roles, :updated_at, :timestamp
  end
end
