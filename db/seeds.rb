require 'csv'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

ct_allen_address = Address.create(
  :address1 => "1210 W. McDermott Drive Suite #104",
  :city => "Allen",
  :state => "TX",
  :postal_code => "75013"
)

ct_allen_contact = User.create(
  :phone => "(972) 740-9944",
  :fax => "(972) 767-4301"
)

ct_allen = Franchisee.create(
  :franchise_name => 'Closet Tailors of Allen, TX'
)

ct_allen.franchisee_addresses.create(
  :address_id => ct_allen_address.id,
  :address_type => 'shipping'
)

#ct_allen.franchisee_contacts.create(
#  :user_id => ct_allen_contact.id,
#  :contact_type => 'primary'
#)

seed_data_dir = "#{File.dirname(__FILE__)}/seed_data"

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

dv_colors    = data_map("#{seed_data_dir}/dvinci_colors.csv")
dv_materials = data_map("#{seed_data_dir}/dvinci_materials.csv")
dv_edgeband  = data_map("#{seed_data_dir}/dvinci_edgeband.csv")
dv_edgeband2 = data_map("#{seed_data_dir}/dvinci_edgeband2.csv")

color_attr = ItemAttr.find_or_create_by_name('Cabinet Color', :value_type => 'string')
material_attr = ItemAttr.find_or_create_by_name('Case Material', :value_type => 'string')
edgeband_attr = ItemAttr.find_or_create_by_name('Case Edge', :value_type => 'string')
edgeband2_attr = ItemAttr.find_or_create_by_name('Case Edge2', :value_type => 'string')

CSV.open("#{seed_data_dir}/parts_closettailors.csv", "r") do |row|
  part_id, catalog_id, dvinci_id, description, *xs = row
  next if part_id == 'PartID'

	product_code_matchdata = dvinci_id.match(/(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})/)
  if product_code_matchdata.nil?
    puts "Could not determine product information for row: #{row.inspect}"
  else
    t1, t2, t3, color_key, t5 = product_code_matchdata.captures
    item_dvinci_key = "#{t1}.#{t2}.#{t3}.x.#{t5}"

    color = dv_colors.has_key?(color_key) ? dv_colors[color_key].call(description) : nil
    base_description = color.nil? ? description : description.gsub(/,\s*#{color}/i, '')
    skip_attrs = base_description == description

    # restore the original description and 15-digit id if the color was not found in the description
    if skip_attrs
      item_dvinci_key = dvinci_id
      puts "Unknown product color; using original dvinci id #{dvinci_id} for #{description}"
    end

    item = Item.find_or_create_by_dvinci_id(
      item_dvinci_key,
      :name => base_description,
      :description => base_description
    )

    unless skip_attrs
      add_item_attr_option = lambda do |attr, from|
        value = from.has_key?(color_key) ? from[color_key].call(description) : nil
        ItemAttrOption.find_or_create_by_item_id_and_item_attr_id_and_dvinci_id(item.id, attr.id, color_key, :value_str => value) if value
      end

      add_item_attr_option.call(color_attr,     dv_colors)
      add_item_attr_option.call(material_attr,  dv_materials)
      add_item_attr_option.call(edgeband_attr,  dv_edgeband)
      add_item_attr_option.call(edgeband2_attr, dv_edgeband2)
    end
  end
end


CSV.open("#{seed_data_dir}/vtiger_products.csv", "r") do |row|
  next if row[0] == "Product Name"

  cutrite_id = row[8]
  dvinci_id = row[3]
	matchdata = dvinci_id.match(/(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})/)
  if matchdata
    t1, t2, color_key, t3 = matchdata.captures
    item = Item.find_by_dvinci_id("000.#{t1}.#{t2}.#{color_key}.#{t3}") || Item.find_by_dvinci_id("000.#{t1}.#{t2}.x.#{t3}")

    if (item)
      item.cutrite_id = cutrite_id
      item.save
    end
  end
end