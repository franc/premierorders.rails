class CreateJobItemComponents < ActiveRecord::Migration
  def self.up
    create_table :job_item_components do |t|
      t.references :item
      t.references :job_item
      t.decimal :unit_cost, :precision => 8, :scale => 2
      t.string :cost_calc_err
      t.integer :quantity
      t.string :qty_calc_err

      t.timestamps
    end

    JobItem.all.each do |job_item|
      job_item.update_cached_values(:mm)
      puts "About to save job item with cached values: #{job_item.pricing_cache_status}; #{job_item.computed_unit_price}; #{job_item.unit_hardware_cost}"
      job_item.save
    end
  end

  def self.down
    drop_table :job_item_components
  end
end
