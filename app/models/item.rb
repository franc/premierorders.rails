require 'property.rb'
require 'util/option'
require 'expressions'
require 'monoid'
require 'semigroup'

class Item < ActiveRecord::Base
  include Expressions, Items::Margins, Items::Surcharges, Items::Pricing

  has_many :item_properties, :dependent => :destroy
	has_many :properties, :through => :item_properties, :extend => Properties::Association

  has_many :item_components, :dependent => :destroy
  has_many :components, :through => :item_components, :class_name => 'Item'

  has_many :job_items

  def self.execute_sql(array)     
    sql = self.send(:sanitize_sql_array, array)
    self.connection.execute(sql)
  end

  def self.search(types, term)
    Item.find_by_sql(["SELECT * FROM items WHERE type in(?) and name ILIKE ?", types, "%#{term}%"]);
  end

  def self.find_by_concrete_dvinci_id(id)
    Option.new(find_by_dvinci_id(id)).orElseLazy do
      product_code_matchdata = id.match(/(\d{3})\.(\w{3})\.(\w{3})\.(\w{3})\.(\d{2})(\w)/)
      if !product_code_matchdata.nil?
        t1, t2, t3, color_key, t5, t6 = product_code_matchdata.captures
        results = find_by_sql(["SELECT * FROM items WHERE dvinci_id LIKE ?", "#{t1}.#{t2}.%.%.#{t5}#{t6}"])
        if results.length == 1
          Option.some(results[0])
        else
          Option.new(
            results.detect do |item|
              md = item.dvinci_id.match(/(\d{3})\.(\w{3})\.(\w+)\.(\w+)\.(\d{2})(\w)/)
              item.color_opts.any?{|opt| opt.respond_to?(:dvinci_id) && opt.dvinci_id.strip == color_key} &&
              t3 =~ /^#{md.captures[2].gsub(/x/,'')}/
            end
          )
        end
      else
        Option.new(find_by_dvinci_id(id))
      end
    end
  end

  def self.item_types 
    [
      Item,
      Cabinet,
      CornerCabinet,
      Countertop,
      Shell,
      Panel,
      Door,
      PremiumDoor,
      PremiumDrawerfront,
      FrenchLiteDoor,
      Drawer,
      ClosetPartition,
      ClosetShelf,
      BackingPanel,
      ScaledItem
    ]
  end

  def self.component_association_modules(mod)
    types = {} 
    if mod.respond_to?(:component_association_types)
      mod.component_association_types.each do |k, t|
        types[k] ||= []
        types[k] += t
      end
    end
    types
  end

  def self.component_association_types
    {:optional => [ItemHardware]}
  end

  def self.optional_properties
    [MARGIN, SURCHARGE, RANGED_SURCHARGE, LINEAR]
  end

  def property_value(descriptor)
    properties.find_by_descriptor(descriptor).property_values.first
  end

  def apply_retail_multiplier(expr)
    div(expr, term(retail_multiplier))
  end

  def apply_rebate_factor(expr)
    div(expr, term(rebate_factor))
  end

  def price_expr(units, color, contexts)
    rebated_cost_expr(units, color, contexts).map{|e| apply_retail_multiplier(e)}
  end

  def rebated_cost_expr(units, color, contexts)
    cost_expr(units, color, contexts).map{|e| apply_rebate_factor(e)}
  end

  def cost_expr(units, color, contexts)
    base_expr = self.base_price.nil? || self.base_price == 0 ? [] : [term(self.base_price)]
    property_pricing = self.property_pricing_expr(units).to_a
    
    selected_component_associations = if contexts.nil? || contexts.empty?
      item_components
    else
      # Find each component association where the context list for that association
      # contains at least one of the contexts specified to this method.
      item_components.select do |comp|
        (comp.contexts - contexts).size < comp.contexts.size
      end
    end

    component_exprs = selected_component_associations.inject([]) do |exprs, assoc| 
      assoc.cost_expr(units, color, contexts).map{|e| exprs << e}.orSome(exprs)
    end

    subtotal_exprs = base_expr + property_pricing + component_exprs + surcharge_exprs(units)
    if subtotal_exprs.empty?
      logger.info("No pricing expression derived for #{self.name} (base price #{self.base_price})")
      Option.none()
    else
      Option.some(apply_margin(sum(*subtotal_exprs)))
    end
  end

  def component_contexts
    item_components.inject([]) {|contexts, comp| contexts + comp.contexts}.uniq
  end

  def color_opts
    opts = self.respond_to?(:color_options) ? self.color_options : []
    item_components.inject(opts) do |options, comp|
      options + comp.color_opts 
    end
  end

  def components_ok?
    required_modules = Item.component_association_modules(self.class)[:required]
    required_present = required_modules.nil? || required_modules.inject(true) do |result, mod| 
      result && !item_components.detect{|v| v.class == mod}.nil?
    end

    item_components.inject(required_present) do |result, comp|
      result && comp.component_ok?
    end    
  end

  def component_errors
    required_modules = Item.component_association_modules(self.class)[:required]
    absent = []
    unless required_modules.nil? 
      required_modules.each do |mod| 
        absent << mod if item_components.detect{|v| v.class == mod}.nil? 
      end
    end

    broken = item_components.inject([]) do |result, comp|
      comp.component_ok? ? result : result << comp
    end    

    {:missing => absent, :broken => broken}
  end

  def properties_ok?
    Property.descriptors(self.class, :required).inject(true) do |result, desc|
      prop = properties.find_by_descriptor(desc)
      result && !prop.nil? && prop.property_values.length > 0
    end
  end

  def property_errors
    absent = []
    broken = []
    Property.descriptors(self.class, :required).each do |desc|
      prop = properties.find_by_descriptor(desc)
      absent << desc if prop.nil? 
      broken << prop if prop && prop.property_values.length == 0
    end

    {:missing => absent, :broken => broken}
  end

  def query(item_query, contexts)
    item_query.traverse_item(self, contexts)
  end

  def weight_expr(units, contexts)
    query(PropertySum.new(units){|item| item.weight}, contexts)
  end

  def install_cost_expr(units, contexts)
    query(PropertySum.new(units){|item| item.install_cost}, contexts)
  end

  def next_item
    Item.find_by_sql(['SELECT * FROM items where name in (select min(name) from items where name > ?)', self.name])
  end

  def previous_item
    Item.find_by_sql(['SELECT * FROM items where name in (select max(name) from items where name < ?)', self.name])
  end
end

class HardwareQuery < ItemQuery
  def initialize(&item_test)
    super(Monoid::ARRAY_APPEND)
    @item_test = item_test
  end

  def query_item_component(assoc, contexts)
    hardware = assoc.kind_of?(ItemHardware) && (@item_test.nil? || @item_test.call(assoc.component)) ? [assoc] : []
    super(assoc, contexts) + hardware
  end
end

class PropertySum < ItemQuery
  include Expressions

  def initialize(units, &prop)
    super(Monoid::OptionM.new(Semigroup::SUM))
    @prop = prop
    @units = units
  end

  def query_item(item)
    Option.new(@prop.call(item)).map{|w| term(w)}
  end

  def query_item_component(assoc, contexts)
    assoc.component.query(self, contexts).map{|expr| assoc.qty_expr(@units) * expr}
  end
end

require 'items/cabinet.rb'
require 'items/corner_cabinet.rb'
require 'items/shell.rb'
require 'items/panel.rb'
require 'items/countertop.rb'
require 'items/door.rb'
require 'items/drawer.rb'
require 'items/closet_partition.rb'
require 'items/closet_shelf.rb'
require 'items/backing_panel.rb'
require 'items/item_hardware.rb'
require 'items/scaled_item.rb'

