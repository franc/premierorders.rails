require 'csv'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

@seed_data_dir = "#{File.dirname(__FILE__)}/seed_data"

PASSWORD_SYMBOLS = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
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
    shipping_address = Address.create(
      :address1 => row[cols.index("Shipping Address")],
      :city => row[cols.index("Shipping City")],
      :state => row[cols.index("Shipping State")],
      :postal_code => row[cols.index("Shipping Postal Code")],
      :country => row[cols.index("Shipping Country")]
    )

    billing_address = Address.new(
      :address1 => row[cols.index("Billing Address")],
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

    contact = User.create(
      :first_name => cols.index("Contact Name") && row[cols.index("Contact Name")][/(.*) (.*)/,1],
      :last_name => cols.index("Contact Name") && row[cols.index("Contact Name")][/(.*) (.*)/,2],
      :email => row[cols.index("Email")],
      :phone => row[cols.index("Other Phone")],
      :password => random_password(10)
    )

    franchisee = Franchisee.create(
      :franchise_name => row[cols.index("Account Name")],
      :phone => row[cols.index("Phone")],
      :fax => row[cols.index("Fax")]
    )

    FranchiseeContact.create(:franchisee_id => franchisee.id, :user_id => contact.id, :contact_type => 'primary')
    FranchiseeAddress.create(:franchisee_id => franchisee.id, :address_id => billing_address.id, :address_type => 'billing')
    FranchiseeAddress.create(:franchisee_id => franchisee.id, :address_id => shipping_address.id, :address_type => 'shipping')
  end
end

def load_product_data(filename)
  ItemAttrOption.delete_all
  Item.delete_all

  def prefix_match(string, prefixes)
    string.match("^(#{prefixes.map{|p| "(#{p})"}.join("|")})")
  end

  def data_map(filename)
    IO.readlines(filename).inject({}) do |m, line|
      id, old_value, new_value, *prefixes = line.split(",")
      if m.has_key?(id)
        delegate = m[id]
        m[id] = lambda do |description|
          (prefixes.empty? || prefix_match(description, prefixes)) ? new_value.strip : delegate.call(description)
        end
      else
        m[id] = lambda do |description|
          (prefixes.empty? || prefix_match(description, prefixes)) ? new_value.strip : nil
        end
      end
      m
    end
  end

  dv_colors    = data_map("#{@seed_data_dir}/dvinci_colors.csv")
  dv_materials = data_map("#{@seed_data_dir}/dvinci_materials.csv")
  dv_edgeband  = data_map("#{@seed_data_dir}/dvinci_edgeband.csv")
  dv_edgeband2 = data_map("#{@seed_data_dir}/dvinci_edgeband2.csv")

  color_attr = ItemAttr.find_or_create_by_name('Cabinet Color', :value_type => 'string')
  material_attr = ItemAttr.find_or_create_by_name('Case Material', :value_type => 'string')
  edgeband_attr = ItemAttr.find_or_create_by_name('Case Edge', :value_type => 'string')
  edgeband2_attr = ItemAttr.find_or_create_by_name('Case Edge2', :value_type => 'string')
  doormatr_attr = ItemAttr.find_or_create_by_name('Door Material', :value_type => 'string')
  dooredge_attr = ItemAttr.find_or_create_by_name('Door Edge', :value_type => 'string')

  purchase_types = {
    'P' => 'Purchased',
    'I' => 'Inventory',
    'M' => 'Manufactured'
  }

  CSV.open("#{@seed_data_dir}/#{filename}", "r") do |row|
    part_id, catalog_id, dvinci_id, description, *xs = row
    next if part_id == 'PartID'

    dvinci_id_matchdata = dvinci_id.match(/(\w{3})\.(\w{3})\.(\w{3})\.(\d{3})\.(\d{2})(\w)/)
    if dvinci_id_matchdata.nil?
      puts "Could not determine product information for row: #{row.inspect}"
    else
      t1, t2, t3, color_key, t5, purchasing = dvinci_id_matchdata.captures

      color = dv_colors.has_key?(color_key) ? dv_colors[color_key].call(description) : nil
      base_description = color.nil? ? description : description.gsub(/,?\s*#{color}/i, '')
      color_match = base_description != description

      # restore the original description and 15-digit id if the color was not found in the description
      # rewrite the item name only for manufactured products; need distinct purchasing skus for different manufactured products.
      item_dvinci_key = (purchasing == 'M' && color_match) ? "#{t1}.#{t2}.#{t3}.x.#{t5}#{purchasing}" : dvinci_id
      item_desc = (purchasing == 'M' && color_match) ? base_description : description

      item = Item.find_or_create_by_dvinci_id(
        item_dvinci_key,
        :name => item_desc,
        :description => item_desc,
        :purchasing => purchase_types[purchasing]
      )

      if color_match
        add_item_attr_option = lambda do |attr, from|
          value = from.has_key?(color_key) ? from[color_key].call(description) : nil
          ItemAttrOption.find_or_create_by_item_id_and_item_attr_id_and_dvinci_id(item.id, attr.id, color_key, :value_str => value) if value
        end

        add_item_attr_option.call(color_attr,     dv_colors)
        add_item_attr_option.call(material_attr,  dv_materials)
        add_item_attr_option.call(edgeband_attr,  dv_edgeband)
        add_item_attr_option.call(edgeband2_attr, dv_edgeband2)
        add_item_attr_option.call(doormatr_attr,  dv_materials)
        add_item_attr_option.call(dooredge_attr,  dv_edgeband)
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
  color_attr = ItemAttr.find_by_name('Cabinet Color')
  File.open("generated_tab.csv", "w") do |out|
    CSV.open("#{@seed_data_dir}/#{filename}", "r") do |row|
      part_id, catalog_id, dvinci_id, description, *xs = row
      next if part_id == 'PartID'

      dvinci_id_matchdata = dvinci_id.match(/(\w{3})\.(\w{3})\.(\w{3})\.(\d{3})\.(\d{2})(\w)/)
      t1, t2, t3, color_key, t5, purchasing = dvinci_id_matchdata.captures

      item_dvinci_key = "#{t1}.#{t2}.#{t3}.x.#{t5}#{purchasing}"
      item = Item.find_by_dvinci_id(item_dvinci_key) || Item.find_by_dvinci_id(dvinci_id)
      if item.nil? 
        puts "Could not find item with dvinci id: " + item_dvinci_key
      else
        color = item.item_attr_options.find_by_item_attr_id_and_dvinci_id(color_attr.id, color_key)
        if color.nil? 
          out.puts(CSV.generate_line([part_id, catalog_id, dvinci_id, item.description] + xs))
        else
          out.puts(CSV.generate_line([part_id, catalog_id, item.dvinci_id.gsub(/x/, color.dvinci_id), "#{item.description}, #{color.value_str}"] + xs))
        end
      end
    end
  end
end

#load_franchisees("franchisee_accounts.csv")
#load_franchisees("franchisee_accounts2.csv")
#load_product_data("parts_closettailors_r1.csv")
#fix_cutrite_codes
dump_tab_file("parts_closettailors_r1.csv")


