class AddCreditStatusToFranchisee < ActiveRecord::Migration
  def self.up
    add_column :franchisees, :credit_status, :string
  end

  def self.down
    remove_column :franchisees, :credit_status
  end
end
