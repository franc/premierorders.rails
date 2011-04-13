require 'csv'
require 'set'

class AddCtopScalingProperties < ActiveRecord::Migration
  def self.up
    pv_specs = {}
    pset_specs = {}
    CSV.open("db/seed_data/ctop_items.csv", "r") do |row|
      name, min, max, price = row
      pv_specs[[min, max, price]] ||= []
      pv_specs[[min, max, price]] << name

      pset_specs[name] ||= Set.new
      pset_specs[name].add([min, max, price])
    end

    pvalues = {}
    pv_specs.each do |mmp, names|
      styles = names.map{|n| style(n)}.to_set
      colors = names.map{|n| color(n)}.to_set
      
      pvalues[mmp] = PropertyValue.create(
        :name => %Q(CTOP Ranged Price #{styles.to_a.compact.sort.join(", ")}: #{colors.to_a.compact.sort.join(", ")} #{mmp[0]}"-#{mmp[1]}"),
        :module_names => 'RangedValue',
        :value_str => %Q({"min":"#{mmp[0]}","max":"#{mmp[1]}","value":"#{mmp[2]}","variable_units":"in","variable":"width"})
      )
    end

    prop_sets = {}
    pset_specs.each do |name, set|
      prop_sets[set] ||= []
      prop_sets[set] << name
    end

    prop_sets.each do |set, names|
      styles = names.map{|n| style(n)}.to_set
      colors = names.map{|n| color(n)}.to_set
      prop = Property.create(
        :name => %Q(CTOP Ranged Price #{styles.to_a.compact.sort.join(", ")}: #{colors.to_a.compact.sort.join(", ")}),
        :family => 'ranged_price',
        :module_names => 'RangedValue'
      )

      set.each do |mmp|
        prop.property_values << pvalues[mmp]
      end

      prop.save

      names.each do |name|
        item = Item.find_by_name(name.strip)
        item.properties << prop
        item.save
      end
    end
  end

  def self.style(name)
    name.strip[/^CTOP - (\w+)/, 1]
  end

  def self.color(name)
    name.strip[/.* \d+ ([\w\s]*)$/, 1]
  end

  def self.down
  end
end
