require 'property.rb'

class Item < ActiveRecord::Base
  has_many :item_properties
	has_many :properties, :through => :item_properties, :extend => Properties::Association

  has_many :item_components
  has_many :components, :through => :item_components, :class_name => 'Item'

  has_many :job_items

  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end

  def self.item_types 
    [
      Item,
      Cabinet,
      CornerCabinet,
      Shell,
      Panel,
      PremiumDoor,
      PremiumDrawerfront,
      FrenchLiteDoor,
      Drawer
    ]
  end

  def self.component_modules(mod)
    types = []
    types += mod.component_types if mod.respond_to?(:component_types)
    types
  end

  def self.component_association_modules(mod)
    types = []
    ActiveRecord::Base.logger.info mod.inspect
    types += mod.component_association_types if mod.respond_to?(:component_association_types)
    types
  end

  def self.search(types, term)
    Item.find_by_sql(["SELECT * FROM items WHERE type in(?) and name ILIKE ?", types, "%#{term}%"]);
  end

  def property_value(descriptor)
    properties.find_by_descriptor(descriptor).property_values.first
  end

  def price_job_item(job_item)
    job_item.unit_price || 0.0
  end

  def pricing_expr(units, color)
    item_components.
    inject([]) {|exprs, component| exprs << component.pricing_expr(units, color)}.
    map{|e| "(#{e})"}.join(" + ")
  end
end

require 'items/cabinet.rb'
require 'items/shell.rb'
require 'items/panel.rb'
require 'items/door.rb'
require 'items/drawer.rb'

