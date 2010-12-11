require 'set'

class NormalizeItemAttrOptions < ActiveRecord::Migration
  class ItemAttr < ActiveRecord::Base
  end

  class ItemAttrOption < ActiveRecord::Base
  end

  class ItemProperty < ActiveRecord::Base
  end

  class Property < ActiveRecord::Base
  end

  def self.up
    execute "alter table franchisees alter column credit_status type varchar(32);"
    execute "alter table items alter column purchasing type varchar(32);"
    execute "alter table jobs alter column status type varchar(32);"

    create_table :item_properties do |t|
      t.references :item
      t.references :property 
      t.string :qualifier
    end

    create_table :properties do |t|
      t.string :name
      t.string :family
      t.string :modules
      t.timestamps
    end

    create_table :property_value_selection, :id => false do |t|
      t.references :property
      t.references :property_value
    end

    drop_table    :item_attrs

    remove_column :item_attr_options, :item_id
    remove_column :item_attr_options, :item_attr_id
    rename_table  :item_attr_options, :property_values

    add_column    :property_values, :name, :string
    add_column    :property_values, :module_names, :string
    remove_column :property_values, :default

    rename_table  :job_item_attributes, :job_item_properties
    remove_column :job_item_properties, :item_attr_id
    add_column    :job_item_properties, :family,    :string
    add_column    :job_item_properties, :qualifier, :string
    add_column    :job_item_properties, :module_names,   :string
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
