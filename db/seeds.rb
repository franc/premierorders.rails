require 'db/seed_loader.rb'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

loader = SeedLoader.new()
loader.load_franchisees("franchisee_accounts.csv")
loader.load_users("franchisee_contacts.csv")
loader.load_product_data("parts_closettailors.csv")
loader.load_decore_pricing
#loader.fix_cutrite_codes
#loader.dump_tab_file("parts_closettailors.csv")
#loader.dump_items


