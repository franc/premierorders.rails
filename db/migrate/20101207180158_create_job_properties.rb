class CreateJobProperties < ActiveRecord::Migration
  def self.up
    create_table :job_properties do |t|
      t.references :job
      t.string :family
      t.string :qualifier
      t.string :module_names
      t.string :value_str

      t.timestamps
    end

    create_table :item_component_properties do |t|
      t.references :item_component
      t.references :property
      t.string :qualifier
    end
  end

  def self.down
    drop_table :job_properties
    drop_table :item_components_properties
  end
end
