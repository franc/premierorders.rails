class CreateComponentConfigurations < ActiveRecord::Migration
  def self.up
    create_table :item_components do |t|
      t.references :item, :null => false
      t.integer :component_id
      t.integer :quantity
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :item_components
  end
end
