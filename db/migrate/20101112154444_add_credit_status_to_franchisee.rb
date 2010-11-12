class AddCreditStatusToFranchisee < ActiveRecord::Migration
  def self.up
    execute "CREATE TYPE credit_status_type AS ENUM ('Green', 'Yellow', 'Red')"
    add_column :franchisees, :credit_status, 'credit_status_type'
  end

  def self.down
    remove_column :franchisees, :credit_status
    execute "DROP TYPE credit_status_type;"
  end
end
