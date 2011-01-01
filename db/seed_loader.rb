require 'csv'
require 'property.rb'

class SeedLoader
  PASSWORD_SYMBOLS = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a

  def initialize()
    @seed_data_dir = "#{File.dirname(__FILE__)}/seed_data"
  end

  def random_password(len)
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
        contact = User.find_or_create_by_email(row[cols.index("Email")].strip, :password => random_password(10), :phone => row[cols.index("Other Phone")])
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
      password = random_password(10)
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


  def load_product_data(filename)
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

    dv_colors    = data_map("#{@seed_data_dir}/dvinci_colors.csv")
    dv_sizes     = IO.readlines("#{@seed_data_dir}/dvinci_panel_categories.csv").inject({}) do |m, line|
      category, notch, *xs = line.split(",")
      m[category.strip] ||= []
      m[category.strip] << notch.strip
      m
    end

    #dv_materials = data_map("#{@seed_data_dir}/dvinci_materials.csv")
    #dv_edgeband  = data_map("#{@seed_data_dir}/dvinci_edgeband.csv")
    #dv_edgeband2 = data_map("#{@seed_data_dir}/dvinci_edgeband2.csv")

    color_props = {
        "Panel" => Property.find_or_create_by_name('Panel Color', :family => 'color'),
        "Premium Panel" => Property.find_or_create_by_name('Premium Panel Color', :family => 'color'),
        "Home Office Panel" => Property.find_or_create_by_name('Home Office Panel Color', :family => 'color'),
        "Hardware" => Property.find_or_create_by_name('Hardware Color', :family => 'color'),
        "Countertop" => Property.find_or_create_by_name('Countertop Color', :family => 'color')
    }

    #material_attr = ItemAttr.find_or_create_by_name('Case Material', :type => 'Material')
    #edgeband_attr = ItemAttr.find_or_create_by_name('Case Edge', :type => 'EdgeBand')
    #edgeband2_attr = ItemAttr.find_or_create_by_name('Case Edge 2', :type => 'EdgeBand')
    #doormatr_attr = ItemAttr.find_or_create_by_name('Door Material', :type => 'Material')
    #dooredge_attr = ItemAttr.find_or_create_by_name('Door Edge', :value_type => 'string')

    purchase_types = {
      'P' => 'Purchased',
      'I' => 'Inventory',
      'M' => 'Manufactured',
      'B' => 'Buyout'
    }

    CSV.open("#{@seed_data_dir}/#{filename}", "r") do |row|
      part_id, catalog_id, dvinci_id, description, *xs = row
      next if part_id == 'PartID' || dvinci_id.nil?

      dvinci_id_matchdata = dvinci_id.match(/(\w{3})\.(\w{3})\.(\w{3})\.(\d{3})\.(\d{2})(\w)/)
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
              a, b, c = t3.split('')
              dv_sizes[t2].detect(a) ? "#{a}x" : t3
          end
               
          o4 = color_match ? 'x' : color_key
          "#{t1}.#{t2}.#{o3}.#{o4}.#{t5}#{purchasing}" 
        else
          dvinci_id
        end

        item_desc = ((purchasing == 'M' || purchasing == 'B') && color_match) ? base_description : description

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

          #add_property_value.call(color_prop,     dv_colors)
          #add_property_value.call(material_attr,  dv_materials)
          #add_property_value.call(edgeband_attr,  dv_edgeband)
          #add_property_value.call(edgeband2_attr, dv_edgeband2)
          #add_property_value.call(doormatr_attr,  dv_materials)
          #add_property_value.call(dooredge_attr,  dv_edgeband)
        end
      end
    end

    #CSV.open("#{@seed_data_dir}/vtiger_products.csv", "r") do |row|
    #  next if row[0] == "Product Name"

    #  cutrite_id = row[8]
    #  dvinci_id = row[3]
    #  matchdata = dvinci_id.match(/(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})/)
    #  if matchdata
    #    t1, t2, color_key, t3 = matchdata.captures
    #    item = Item.find_by_dvinci_id("000.#{t1}.#{t2}.#{color_key}.#{t3}") || Item.find_by_dvinci_id("000.#{t1}.#{t2}.x.#{t3}")

    #    if (item)
    #      item.cutrite_id = cutrite_id
    #      item.save
    #    end
    #  end
    #end
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

  def dump_tab_file(filename)
    File.open("generated_tab.csv", "w") do |out|
      CSV.open("#{@seed_data_dir}/#{filename}", "r") do |row|
        part_id, catalog_id, dvinci_id, description, *xs = row
        next if part_id == 'PartID' || dvinci_id.nil?

        dvinci_id_matchdata = dvinci_id.match(/(\w{3})\.(\w{3})\.(\w{3})\.(\d{3})\.(\d{2})(\w)/)
        if dvinci_id_matchdata.nil?
          puts "Could not parse dvinci id: " + dvinci_id
        else
          t1, t2, t3, color_key, t5, purchasing = dvinci_id_matchdata.captures

          item_dvinci_key = "#{t1}.#{t2}.#{t3}.x.#{t5}#{purchasing}"
          item = Item.find_by_dvinci_id(item_dvinci_key) || Item.find_by_dvinci_id(dvinci_id)
          if item.nil? 
            puts "Could not find item with dvinci id: " + item_dvinci_key
          else
            color_prop = item.properties.find_by_family(:color)
            if color_prop.nil? 
              out.puts(CSV.generate_line([part_id, catalog_id, dvinci_id, item.description] + xs))
            else
        color = color_prop.property_values.detect{|v| !v.nil? && v.dvinci_id == color_key}
              if color.nil?
                out.puts(CSV.generate_line([part_id, catalog_id, dvinci_id, item.description] + xs))
              else
          out.puts(CSV.generate_line([part_id, catalog_id, item.dvinci_id.gsub(/x/, color.dvinci_id), "#{item.description}, #{color.color}"] + xs))
              end
            end
          end
        end
      end
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

