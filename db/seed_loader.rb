require 'csv'
require 'set'
require 'fp'

class SeedLoader
  PASSWORD_SYMBOLS = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a

  def initialize()
    @seed_data_dir = "#{File.dirname(__FILE__)}/seed_data"
  end

  def self.random_password(len)
    Array.new(len){|i| PASSWORD_SYMBOLS[rand(PASSWORD_SYMBOLS.size)]}.join
  end

  def load_franchisees(filename)
    columns = []
    CSV.open("#{@seed_data_dir}/#{filename}", "r") do |row|
      if row[0] == "Account Name"
        columns = row
      else
        create_franchisee_account(row, columns)
      end
    end
  end

  def create_franchisee_account(row, cols)
    unless Franchisee.find_by_franchise_name(row[cols.index("Account Name")])
      shipping_address = Address.find_or_create_by_address1(
        row[cols.index("Shipping Address")],
        :city => row[cols.index("Shipping City")],
        :state => row[cols.index("Shipping State")],
        :postal_code => row[cols.index("Shipping Postal Code")],
        :country => row[cols.index("Shipping Country")]
      )

      billing_address = Address.find_or_create_by_address1(
        row[cols.index("Billing Address")],
        :city => row[cols.index("Billing City")],
        :state => row[cols.index("Billing State")],
        :postal_code => row[cols.index("Billing Postal Code")],
        :country => row[cols.index("Billing Country")]
      )

      if (shipping_address.same_as(billing_address))
        billing_address = shipping_address
      else
        billing_address.save
      end

      franchisee = Franchisee.find_or_create_by_franchise_name(row[cols.index("Account Name")].strip)
      franchisee.update_attributes(
        :phone => row[cols.index("Phone")],
        :fax => row[cols.index("Fax")]
      )

      unless row[cols.index("Email")].nil?
        contact = User.find_or_create_by_email(row[cols.index("Email")].strip, :password => SeedLoader.random_password(10), :phone => row[cols.index("Other Phone")])
        FranchiseeContact.find_or_create_by_franchisee_id_and_user_id(franchisee.id, contact.id, :contact_type => 'primary')
      end

      FranchiseeAddress.find_or_create_by_franchisee_id_and_address_id(franchisee.id, billing_address.id, :address_type => 'billing')
      FranchiseeAddress.find_or_create_by_franchisee_id_and_address_id(franchisee.id, shipping_address.id, :address_type => 'shipping')
    end
  end

  def load_users(filename)
    columns = []
    CSV.open("#{@seed_data_dir}/#{filename}", "r") do |row|
      if row[0] == "Salutation"
        columns = row
      else
        create_user(row, columns)
      end
    end
  end

  def create_user(row, cols) 
    unless row[cols.index("Email")].nil? || row[cols.index("Email")].strip.empty?
      password = SeedLoader.random_password(10)
      user = User.find_by_email(row[cols.index("Email")].strip.downcase)

      user ||= User.create(:email => row[cols.index("Email")].strip.downcase, :password => password)
      user.update_attributes(
        :title => row[cols.index("Salutation")],
        :first_name => row[cols.index("First Name")],
        :last_name => row[cols.index("Last Name")],
        :phone => row[cols.index("Office Phone")],
        :phone2 => row[cols.index("Mobile")],
        :fax => row[cols.index("Fax")]
      )

      franchisee = Franchisee.find_by_franchise_name(row[cols.index("Account Name")])
      if franchisee
        FranchiseeContact.find_or_create_by_franchisee_id_and_user_id(franchisee.id, user.id, :contact_type => 'associate')
      end
    end
  end

  def dv_sizes
    @dv_sizes ||= IO.readlines("#{@seed_data_dir}/dvinci_panel_categories.csv").inject({}) do |m, line|
      category, notch, *xs = line.split(",")
      m[category.strip] ||= []
      m[category.strip] << notch.strip
      m
    end

    @dv_sizes
  end

  def with_tabfile_rows(filename, &block)
    def prefix_match(string, prefixes)
      string.match("^(#{prefixes.map{|p| "(#{p})"}.join("|")})")
    end

    def data_map(filename)
      IO.readlines(filename).inject({}) do |m, line|
        id, category, new_value, *prefixes = line.split(",")
        if m.has_key?(id)
          delegate = m[id]
          m[id] = lambda do |description|
            (prefixes.empty? || prefix_match(description, prefixes)) ? [category, new_value.strip] : delegate.call(description)
          end
        else
          m[id] = lambda do |description|
            (prefixes.empty? || prefix_match(description, prefixes)) ? [category, new_value.strip] : nil
          end
        end
        m
      end
    end

    dv_colors = data_map("#{@seed_data_dir}/dvinci_colors.csv")
    File.open("#{@seed_data_dir}/#{filename}", "r") do |file|
      file.each_line do |line|
        row = line.split("\t")
        part_id, catalog_id, dvinci_id, description, *xs = row
        next if part_id == 'PartID' || dvinci_id.nil?

        dvinci_id_matchdata = dvinci_id.match(/(\w{3})\.(\w{3})\.(\w{3})\.(\w{3})\.(\d{2})(\w)/)
        if dvinci_id_matchdata.nil?
          puts "Could not determine product information for row: #{row.inspect}"
        else
          t1, t2, t3, color_key, t5, purchasing = dvinci_id_matchdata.captures

          category, color = dv_colors.has_key?(color_key) ? dv_colors[color_key].call(description) : [nil, nil]
          base_description = color.nil? ? description : description.gsub(/[,|]?\s*#{color}/i, '')
          color_match = base_description != description

          # restore the original description and 15-digit id if the color was not found in the description
          # rewrite the item name only for manufactured products; need distinct purchasing skus for different 
          # purchased products, even though this means a lot of data duplication
          item_dvinci_key = if purchasing == 'M' || purchasing == 'B'
            o3 = case dv_sizes[t2]
              when nil then t3
              when ['x'] then 'x'
              else
                Option.new(dv_sizes[t2].detect{|n| t3 =~ /^#{n}/}).map{|n| "#{n}x"}.orSome(t3)
            end
                 
            o4 = color_match ? 'x' : color_key
            "#{t1}.#{t2}.#{o3}.#{o4}.#{t5}#{purchasing}" 
          else
            dvinci_id
          end

          item_desc = ((purchasing == 'M' || purchasing == 'B') && color_match) ? base_description : description

          block.call(row, item_dvinci_key, item_desc, purchasing, category, color, color_key, color_match)
        end
      end
    end
  end

  def load_product_data(filename)
    purchase_types = {
      'P' => 'Purchased',
      'I' => 'Inventory',
      'M' => 'Manufactured',
      'B' => 'Buyout'
    }

    color_props = {
      "Panel" => Property.find_or_create_by_name('Panel Color', :family => 'color'),
      "Premium Panel" => Property.find_or_create_by_name('Premium Panel Color', :family => 'color'),
      "Home Office Panel" => Property.find_or_create_by_name('Home Office Panel Color', :family => 'color'),
      "Hardware" => Property.find_or_create_by_name('Hardware Color', :family => 'color'),
      "Countertop" => Property.find_or_create_by_name('Countertop Color', :family => 'color')
    }

    with_tabfile_rows(filename) do |row, item_dvinci_key, item_desc, purchasing, category, color, color_key, color_match|
      item = Item.find_or_create_by_dvinci_id(
        item_dvinci_key,
        :name => item_desc,
        :description => item_desc,
        :purchasing => purchase_types[purchasing]
      )

      color_prop = color_props[category]
      if color_match && color_prop
        item.item_properties.find_or_create_by_item_id_and_property_id(item.id, color_prop.id)
        color_value = color_prop.property_values.find_or_create_by_name_and_dvinci_id(color, color_key)
        color_value.update_attributes(:module_names => 'Color', :value_str => "{\"color\": \"#{color}\"}")
      end
    end
  end

  def fix_cutrite_codes
    column_index = {}
    CSV.open("#{@seed_data_dir}/cutrite_codes.csv", "r") do |row|
      if row[0] && row[0].strip == 'id'
        row.each_with_index do |v, i|
          column_index[v.strip] = i
        end
        puts column_index.inspect
      else
        update_item = lambda do |item|
          # use the original names for purchased parts, since due to the mismatch they've lost color info.
          # otherwise, use the description from the deduped file.
          item.name = row[column_index['description']].strip if row[column_index['purchase_part_id']].nil? 
          item.description = item.name
          item.cutrite_id  = row[column_index['cutrite_id']].strip if !row[column_index['cutrite_id']].nil?
          item.purchase_part_id = row[column_index['purchase_part_id']].strip if !row[column_index['purchase_part_id']].nil?
          item.save
        end

        dvinci_id = row[column_index['dvinci_id']].strip
        if (!dvinci_id.nil?)
          item = Item.find_by_dvinci_id(dvinci_id)
          if item
            update_item.call(item)
          else
            items = Item.find_by_sql("SELECT * FROM items WHERE dvinci_id LIKE '#{dvinci_id.gsub(/x/, '%')}'") if item.nil?
            if items && !items.empty?
              items.each {|i| update_item.call(i)}
            else
              items = Item.find_by_sql("SELECT * FROM items WHERE dvinci_id LIKE '#{dvinci_id.gsub(/\w$/, '%')}'") 
              if items && !items.empty?
                items.each {|i| update_item.call(i)}
              else
                puts "Could not find item #{row[column_index['description']]} with dvinci id #{dvinci_id}"
              end
            end
          end
        end
      end
    end
  end

  def decore_pricing_data
    style_colors = {}
    option_costs = {}
    handling_costs = {}

    CSV.open("#{@seed_data_dir}/decore_pricing.csv", 'r') do |row| 
      item, mpn, cost, cost_uom, option_cost, option_uom, handling_cost, handling_uom = row

      ref = mpn[/(#.*)/, 1].strip
      id, color, *rest = mpn.gsub(/(,\s*)?#.*/, '').split(',').map{|s| s.strip}
      style = rest.join(', ')

      sref = [style, id]
      style_colors[sref] ||= {}
      if style_colors[sref][color] && style_colors[sref][color] != cost.to_f
        raise "Got a different price for #{sref.inspect} in color #{color}: #{cost}"
      end
      style_colors[sref][color] = cost.to_f

      option_costs[sref] ||= []
      option_costs[sref] << option_cost

      handling_costs[sref] ||= []
      handling_costs[sref] << handling_cost
    end

    material_sets = {}
    style_colors.each do |k, v|
      material_sets[v] ||= []
      material_sets[v] << k
    end

    option_cost_sets = {}
    option_costs.each do |k, v|
      raise "Got more than one option cost for #{k.inspect}" if v.uniq.length > 1
      option_cost_sets[v[0]] ||= []
      option_cost_sets[v[0]] << k
    end
  
    handling_cost_sets = {}
    handling_costs.each do |k, v|
      raise "Got more than one handling cost for #{k.inspect}" if v.uniq.length > 1
      handling_cost_sets[v[0]] ||= []
      handling_cost_sets[v[0]] << k
    end
 
    [material_sets, option_cost_sets, handling_cost_sets]
  end

  # in the decore pricing, material cost varies by color, item, and style.
  # surcharges vary only by style
  def load_decore_pricing
    material_sets, option_costs, handling_costs = decore_pricing_data
    load_decore_materials(material_sets)
    load_decore_surcharges(option_costs, "Options")
    load_decore_surcharges(handling_costs, "Handling")
  end

  def with_decore_items(style, id)
    items = case style
      when "Door" then Item.find_by_sql("SELECT * FROM items WHERE (name LIKE 'Decor Door - #{id}%' OR name LIKE 'Decor Hamper Door - #{id}%') AND name NOT LIKE '%Cut for Glass%'")
      when "Routed DF" then Item.find_by_sql("SELECT * FROM items WHERE name LIKE 'Decor Drawer Front - #{id}%'")
      when "Cut for Glass" then Item.find_by_sql("SELECT * FROM items WHERE name LIKE 'Decor Door - #{id} | Cut for Glass%'")
      else []
    end

    items.each{|item| yield(item)}
  end

  def srefs_desc(srefs)
      styles = []
      items = []
      srefs.each do |pair|
        style, id = pair
        styles << style
        items << id
      end
      styles.uniq!
      items.uniq!

      styles.length > items.length ? items.join("/") : "#{items.join("/")}: #{styles.join(",")}"
  end

  def add_decore_property(srefs, prop)
      srefs.each do |pair|
        style, id = pair
        with_decore_items(style, id) do |item|
          item.item_properties.create(:item_id => item.id, :property_id => prop.id)
        end
      end
  end

  def load_decore_materials(material_sets)
    material_sets.each do |color_prices, srefs|
      desc = srefs_desc(srefs)
      prop = Property.create(:name => "Decore #{desc} Door Material", :family => :door_material, :module_names => 'Material')
      color_prices.each do |color_name, price|
        color = color_name.gsub(/-.*/,'')
        prop.property_values.create(
          :name => "#{desc} #{color} Door Material", 
          :module_names => 'Material', 
          :value_str => %Q({"color": "#{color}", "thickness": 0, "thickness_units": "mm", "price": #{price}, "price_units": "ft"})
        )
      end

      add_decore_property(srefs, prop)
    end
  end

  def load_decore_surcharges(cost_sets, type)
    cost_sets.each do |cost, srefs|
      desc = srefs_desc(srefs)
      prop = Property.create(:name => "Decore #{desc} #{type} Charges", :family => :style_surcharge, :module_names => 'Surcharge')
      prop.property_values.create(
        :name => "#{desc} #{type} Surcharge",
        :module_names => 'Surcharge',
        :value_str => %Q({"price": #{cost}})
      )

      add_decore_property(srefs, prop)
    end
  end

  def dump_tab_file(filename)
    tab_headers = [
      'PartID',
      'CatalogID',
      'PartString',
      'Description',
      'Quantity',
      'Price',
      'Labor',
      'SpecialFlags',
      'Weight',
      'Image'
    ]

    File.open("generated_tab_errors.out", "w") do |err|
    File.open("generated_tab_missing.out", "w") do |missing|
    File.open("generated_tab_mismatch.out", "w") do |mismatch|
    File.open("bridge_generated.tab", "w") do |out|
      out.puts(tab_headers.join("\t"))

      with_tabfile_rows(filename) do |row, item_dvinci_key, item_desc, purchasing, category, color, color_key, color_match|
        part_id, catalog_id, dvinci_id, description, flag, price, *xs = row

        item = Item.find_by_dvinci_id(item_dvinci_key)
        if item.nil? 
          err.puts "Could not find item with dvinci id #{item_dvinci_key} for row #{row.inspect}" 
          missing.puts(row.join("\t"))
          out.puts(row.join("\t").strip)
        else
          begin
            item_pricing_expr = item.retail_price_expr(:in, color_key.gsub(/^[19]/,'0'), []).map{|e| e.compile}.orLazy do
              err.puts "Could not determine pricing expression for row #{row.inspect}"
            end

            if item_pricing_expr != row[5]
              mismatch.puts(CSV.generate_line([dvinci_id, row[5], item_pricing_expr]))
            end

            display_name = color_match ? "#{item.name.gsub(/ \| #{color}/, '')} | #{color}" : item.name
            out.puts(([part_id, catalog_id, dvinci_id, display_name, flag, item_pricing_expr] + xs).join("\t").strip)
          rescue
            err.puts("Error in calculating prices for row #{row.inspect}: #{$!.backtrace[0]}")
          end
        end

        print '.'
        STDOUT.flush
      end
    end
    end
    end
    end
    puts
  end

  def list_unmatched_codes(filename)
    matched = []
    File.open("generated_tab.csv", "w") do |out|
      with_tabfile_rows(filename) do |row, item_dvinci_key, item_desc, purchasing, category, color, color_key, color_match|
        item = Item.find_by_dvinci_id(item_dvinci_key)
        matched << item.dvinci_id unless item.nil?
      end
    end

    results = ActiveRecord::Base.connection.execute('SELECT dvinci_id from items')

    (results.to_a.map{|v| v['dvinci_id']} - matched).select{|id| id != ""}.map do |id| 
      item = Item.find_by_dvinci_id(id)
      [item.dvinci_id, item.name]
    end
  end

  def dump_items
    File.open("generated.csv", 'w') do |f|
      CSV::Writer.generate(f, ",") do |csv|
       Item.find(:all).each do |i|
        csv << [i.name, i.dvinci_id, i.cutrite_id]
       end
      end
    end
  end
end

