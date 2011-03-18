require 'properties'
require 'expressions'
require 'fp'

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

  def self.simple_search(types, term)
    if (types.empty? || (types.length == 1 && types[0] == 'Item'))
      Item.find_by_sql(["SELECT * FROM items WHERE name ILIKE ?", "%#{term}%"])
    else
      Item.find_by_sql(["SELECT * FROM items WHERE type in(?) and name ILIKE ?", types, "%#{term}%"])
    end
  end

  searchable do
    text :name, :boost => 2.0
    text :description
    text :dvinci_id do
      if dvinci_id
        tokens = dvinci_id.split(/\./)
        subsets = (1..tokens.length).inject([]) do |m, l|
          (0..(tokens.length - l)).inject(m) do |mm, i|
            mm << (tokens[i, l].join("."))
          end
        end

        subsets.select{|tok| tok != 'x'}
      end
    end
    string :type
    string :category
    string :purchase_part_id
    string :cutrite_id
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
      Items::SushiListItem,
      Items::Cabinet,
      Items::CornerCabinet,
      Items::Countertop,
      Items::Shell,
      Items::Panel,
      Items::Door,
      Items::PremiumDoor,
      Items::PremiumDrawerfront,
      Items::FrenchLiteDoor,
      Items::Drawer,
      Items::ClosetPartition,
      Items::ClosetShelf,
      Items::BackingPanel,
      Items::MoldingNailer,
      Items::FinishedPanel,
      Items::ScaledItem
    ]
  end

  def self.categories
    self.connection.execute("SELECT DISTINCT category FROM items ORDER BY category").map{|row| row['category']}.compact
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
    {:optional => [Items::ItemHardware]}
  end

  def self.optional_properties
    [MARGIN, SURCHARGE, RANGED_SURCHARGE, LINEAR]
  end

  def property_value(descriptor)
    properties.find_by_descriptor(descriptor).property_values.first
  end

  def apply_retail_multiplier(expr)
    Option.new(retail_multiplier).map{|m| div(expr, term(m))}.orSome(expr)
  end

  def apply_rebate_factor(expr)
    Option.new(rebate_factor).map{|f| div(expr, term(f))}.orSome(expr)
  end

  def retail_price_expr(units, color, contexts)
    wholesale_price_expr(units, color, contexts).map{|e| apply_retail_multiplier(e)}
  end

  # For the wholesale price, any explicit sell price value will override
  # a price derived from assembly component values
  def wholesale_price_expr(units, color, contexts)
    Option.new(sell_price).filter{|p| p != 0}.map{|p| term(p)}.orElseLazy do
      rebated_cost_expr(units, color, contexts)
    end
  end

  def rebated_cost_expr(units, color, contexts)
    cost_expr(units, color, contexts).map{|e| apply_rebate_factor(e)}
  end

  def cost_expr(units, color, contexts)
    base_expr = Option.new(base_price).filter{|p| p != 0}.map{|p| term(p)}.to_a
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
    query(ItemQueries::PropertySum.new(units){|item| item.weight}, contexts)
  end

  def install_cost_expr(units, contexts)
    query(ItemQueries::PropertySum.new(units){|item| item.install_cost}, contexts)
  end

  def next_item
    Item.find_by_sql(['SELECT * FROM items where name in (select min(name) from items where name > ?)', self.name])
  end

  def previous_item
    Item.find_by_sql(['SELECT * FROM items where name in (select max(name) from items where name < ?)', self.name])
  end
end
