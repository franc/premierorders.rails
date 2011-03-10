class AddPriceCacheToJobItem < ActiveRecord::Migration
  def self.up
    add_column :job_items, :cache_calculation_units, :string
    add_column :job_items, :pricing_cache_status, :string
    add_column :job_items, :computed_unit_price, :decimal, :precision => 8, :scale => 2
    add_column :job_items, :unit_hardware_cost, :decimal, :precision => 8, :scale => 2
    add_column :job_items, :unit_install_cost,  :decimal, :precision => 8, :scale => 2
    add_column :job_items, :unit_weight, :float
  end

  def self.down
    remove_column :job_items, :unit_weight
    remove_column :job_items, :unit_install_cost
    remove_column :job_items, :unit_hardware_cost
    remove_column :job_items, :computed_unit_price
    remove_column :job_items, :pricing_cache_status
    remove_column :job_items, :cache_calculation_units
  end
end
