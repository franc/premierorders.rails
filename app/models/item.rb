require 'property.rb'

class Item < ActiveRecord::Base
  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end

  def self.item_types 
    [
      Cabinet,
      Shell,
      Panel,
      PremiumDoor,
      FrenchLiteDoor,
      Drawer
    ]
  end

  has_many :item_properties
	has_many :properties, :through => :item_properties, :extend => Properties::Association

  has_many :item_components
  has_many :components, :through => :item_components, :class_name => 'Item'

  def self.search(types, term)
    Item.find_by_sql(["SELECT * FROM items WHERE type in(?) and name ILIKE ?", types, "%#{term}%"]);
  end

  def compute_price(job_item)
    job_item.quantity * job_item.unit_price
  end
end

require 'items/cabinet.rb'
require 'items/shell.rb'
require 'items/panel.rb'
require 'items/door.rb'
require 'items/drawer.rb'

