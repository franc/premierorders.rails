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

    dvinci_ids = {}
    attr_map = {} 
    execute("select distinct item_id, item_attr_id, dvinci_id, value_str from item_attr_options").each do |row|
      key = [row['item_id'], row['item_attr_id']]

      attr_map[key] = Set.new() unless attr_map[key]
      attr_map[key].add(row['value_str'])

      dv_key = [row['item_attr_id'], row['value_str']]
      dvinci_ids[dv_key] = row['dvinci_id']
    end

    inverted = {}
    attr_map.each do |item_id, attr_values|
      inverted[attr_values] = Set.new() unless inverted[attr_values]
      inverted[attr_values].add(item_id)
    end

    attr_translation = {
      "Cabinet Color" => ['Color', 'Color'],
      "Case Material" => ['Case Material', 'Material'],
      "Case Edge" => ['Case Edge', 'EdgeBand'],
      "Case Edge2" => ['Case Edge 2', 'EdgeBand'],
      "Door Material" => ['Door Material', 'Material'],
      "Door Edge" => ['Door Edge', 'EdgeBand'],
    }

    create_table :item_properties do |t|
      t.references :item
      t.references :property 
      t.string :qualifier
    end

    create_table :properties do |t|
      t.string :name
      t.string :modules
      t.timestamps
    end

    create_table :property_value_selection, :id => false do |t|
      t.references :property
      t.references :property_value
    end

    remove_column :item_attr_options, :item_id
    remove_column :item_attr_options, :item_attr_id

    ItemAttrOption.delete_all

    # for each member of the inverted map, create a new attribute set
    new_attr_options = {}
    inverted.each do |attr_values, items|
      old_attr_ids = items.inject(Set.new()) do |cur, v|
        item_id, attr_id = v
        cur.add(attr_id)
      end

      old_attr_ids.each do |id|
        old_attr = ItemAttr.find_by_id(id)
        unless attr_values.empty?
          property = Property.create(:name => attr_translation[old_attr.name][0], :modules => attr_translation[old_attr.name][1])

          attr_values.each do |value|
            dvinci_id_key = [id, value]
            puts old_attr.name, attr_translation[old_attr.name][1]
            option = (new_attr_options[dvinci_id_key] || ItemAttrOption.create(:value_str => value, :dvinci_id => dvinci_ids[dvinci_id_key]))
            new_attr_options[dvinci_id_key] ||= option
            execute "insert into property_value_selection (property_id, property_value_id) values (#{property.id}, #{option.id});"
          end

          items.map{|v| v[0]}.uniq.each do |item_id|
            ItemProperty.create(:item_id => item_id, :property_id => property.id)
          end
        end
      end 
    end

    drop_table    :item_attrs
    rename_table  :item_attr_options, :property_values
    add_column    :property_values, :name, :string
    remove_column :property_values, :default

    rename_table  :job_item_attributes, :job_item_properties
    rename_column :job_item_properties, :item_attr_id, :property_id

    rename_table  :pricing_attr_options, :pricing_property_values
    rename_column :pricing_property_values, :item_attr_option_id, :property_value_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new()
  end
end
