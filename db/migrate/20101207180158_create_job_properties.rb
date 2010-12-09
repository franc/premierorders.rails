class CreateJobProperties < ActiveRecord::Migration
  def self.up
    create_table :job_properties do |t|
      t.references :job
      t.references :property
      t.string :value_str

      t.timestamps
    end

    create_table :item_component_properties do |t|
      t.references :item_component
      t.references :property
      t.string :qualifier
    end

    add_column :properties, :family, :string
    rename_column :properties, :modules, :module_names
  end

  def self.down
    drop_table :job_properties
    drop_table :item_components_properties
  end
end
