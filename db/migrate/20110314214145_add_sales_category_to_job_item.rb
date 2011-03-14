class AddSalesCategoryToJobItem < ActiveRecord::Migration
  def self.up
    add_column :job_items, :sales_category, :string
  end

  def self.down
    remove_column :job_items, :sales_category
  end
end
