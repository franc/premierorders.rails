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

ct_allen.franchisee_contacts.create(
  :user_id => ct_allen_contact.id,
  :contact_type => 'primary'
)

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
        (prefixes.empty? || prefix_match(description, prefixes)) ? new_value : delegate.call(description)
      end
    else
      m[id] = lambda do |description|
        (prefixes.empty? || prefix_match(description, prefixes)) ? new_value : nil
      end
    end
    m
  end
end

dv_colors    = data_map("#{seed_data_dir}/dvinci_cabinet_color.csv")
dv_materials = data_map("#{seed_data_dir}/dvinci_materials.csv")
dv_edgeband  = data_map("#{seed_data_dir}/dvinci_edgeband.csv")
dv_edgeband2 = data_map("#{seed_data_dir}/dvinci_edgeband2.csv")

CSV.open("#{seed_data_dir}/parts_closettailors.csv", "r") do |row|
  part_id, catalog_id, dvinci_id, description, *xs = row
  next if part_id == 'PartID'

	product_code_matchdata = dvinci_id.match(/(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})/)
  t1, t2, t3, color_key, t5 = product_code_matchdata.captures
  item_dvinci_key = "#{t1}.#{t2}.#{t3}.x.#{t5}"
  item = Item.find_or_create_by_dvinci_id(
    item_dvinci_key,
    :name => description,
    :description => description
  )

  color_attr = item.item_attrs.find_or_create_by_name('Cabinet Color') {|a| a.value_type = 'string'}
  described_color = description[/.*,(.*)/, 1]
  color = dv_colors.has_key?(color_key) ? dv_colors[color_key].call(description) : described_color
  if (!color.nil? && !described_color.nil? && color.strip.casecmp(described_color.strip) != 0)
    raise "color/key mismatch for item #{dvinci_id}; expected #{color} but got #{described_color}"
  end
  color_attr.attribute_options.find_or_create_by_dvinci_id(color_key) {|a| a.value_str = color}

  add_item_attr_option = lambda do |name, from|
    value = from.has_key?(color_key) ? from[color_key].call(description) : nil
    material_attr = item.item_attrs.find_or_create_by_name(name) {|a| a.value_type = 'string'}
    material_attr.attribute_options.find_or_create_by_dvinci_id(color_key) {|a| a.value_str = value}
  end

  add_item_attr_option.call('Case Material', dv_materials)
  add_item_attr_option.call('Case Edge',     dv_edgeband)
  add_item_attr_option.call('Case Edge2',    dv_edgeband2)
end

