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
      Door,
      PremiumDoor,
      PremiumDrawerfront,
      FrenchLiteDoor,
      Drawer,
      ClosetPartition,
      ClosetShelf
    ]
  end

  def self.component_modules(mod)
    types = []
    types += mod.component_types if mod.respond_to?(:component_types) 
    types
  end

  def self.component_association_modules(mod)
    types = {:optional => [ItemHardware]} # anything can have hardware
    if mod.respond_to?(:component_association_types)
      mod.component_association_types.each do |k, t|
        types[k] ||= []
        types[k] + t
      end
    end
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
    base_expr = Option.new(base_price)
    if item_components.empty?
      base_expr.orSome(0.0)
    else
      component_expr = "(#{item_components.inject([]) {|exprs, component| exprs << component.pricing_expr(units, color)}.join(" + ")})"
      base_expr.map{|e| "(#{e} + #{component_expr})"}.orSome(component_expr)
    end
  end

  def color_opts
    opts = self.respond_to?(:color_options) ? self.color_options : []
    item_components.inject(opts) do |options, comp|
      options +  comp.color_opts 
    end
  end

  def components_ok?
    required_modules = Item.component_association_modules(self.class)[:required]
    required_present = required_modules.nil? || required_modules.inject(true) do |result, kv|
      result && !item_components.detect{|v| v.class == kv[1]}.nil?
    end

    item_components.inject(required_present) do |result, comp|
      result && comp.component_ok?
    end    
  end

  def component_errors
  end

  def properties_ok?
    Property.descriptors(self.class, :required).inject(true) do |result, desc|
      result && !properties.find_by_descriptor(desc).nil?
    end
  end

  def property_errors
  end
end

require 'items/cabinet.rb'
require 'items/corner_cabinet.rb'
require 'items/shell.rb'
require 'items/panel.rb'
require 'items/door.rb'
require 'items/drawer.rb'
require 'items/closet_partition.rb'
require 'items/closet_shelf.rb'
require 'items/item_hardware.rb'

