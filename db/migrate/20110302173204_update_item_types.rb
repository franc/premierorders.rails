class UpdateItemTypes < ActiveRecord::Migration
  def self.up
    execute("update items set type = 'Items::' || type where type not like 'Items%' and type != 'Item'")
    execute("update item_components set type = 'Items::' || type where type not like 'Items%'")
  end

  def self.down
  end
end
