class CreateItemPricings < ActiveRecord::Migration
  def self.up
    create_table :item_pricings do |t|
      t.string :type
      t.float  :cost
      t.string :pricing_units
      t.float  :option_cost
      t.string :option_pricing_units
      t.float  :handling_cost
      t.string :handling_pricing_units

      t.timestamps
    end

    create_table :item_item_pricings, :id => false do |t|
      t.references :item
      t.references :item_pricing
    end

    add_index :item_item_pricings, [:item_id, :item_pricing_id], :unique => true

    create_table :pricing_attr_options, :id => false do |t|
      t.references :item_pricing
      t.references :item_attr_option
    end

    add_index :pricing_attr_options, [:item_pricing_id, :item_attr_option_id], :unique => true
  end

  def self.down
    drop_table :pricing_attr_options
    drop_table :item_item_pricings
    drop_table :item_pricings
  end
end
