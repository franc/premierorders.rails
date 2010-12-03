require 'set'

class NormalizeItemAttrOptions < ActiveRecord::Migration
  class ItemAttr < ActiveRecord::Base
  end

  class ItemAttrOption < ActiveRecord::Base
  end

  class AttrSet < ActiveRecord::Base
  end

  def self.up
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

    create_table :item_attr_sets, :id => false do |t|
      t.references :item
      t.references :attr_set 
    end

    create_table :attr_sets do |t|
      t.string :name
      t.timestamps
    end

    create_table :attr_set_members, :id => false do |t|
      t.references :attr_set
      t.references :item_attr
    end

    remove_column :item_attr_options, :item_id
    remove_column :item_attr_options, :item_attr_id
    add_column :item_attr_options, :value_type, :string

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
          attr_set = AttrSet.create(:name => attr_translation[old_attr.name][0])

          attr_values.each do |value|
            dvinci_id_key = [id, value]
            puts old_attr.name, attr_translation[old_attr.name][1]
            option = (new_attr_options[dvinci_id_key] || ItemAttrOption.create(:value_type => attr_translation[old_attr.name][1], :value_str => value, :dvinci_id => dvinci_ids[dvinci_id_key]))
            new_attr_options[dvinci_id_key] ||= option
            execute "insert into attr_set_members (attr_set_id, item_attr_id) values (#{attr_set.id}, #{option.id});"
          end

          items.map{|v| v[0]}.uniq.each do |item_id|
            execute "insert into item_attr_sets (item_id, attr_set_id) values (#{item_id}, #{attr_set.id});"
          end
        end
      end 
    end

    drop_table :item_attrs
    rename_table :item_attr_options, :item_attrs
    rename_column :item_attrs, :value_type, :type
    drop_column :item_attrs, :default
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new()
  end
end
