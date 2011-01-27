class AddPrimaryContactToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :primary_contact_id, :int
    execute("ALTER TABLE jobs ADD FOREIGN KEY (primary_contact_id) REFERENCES users")
  end

  def self.down
    remove_column :jobs, :primary_contact_id
  end
end
