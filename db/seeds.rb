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