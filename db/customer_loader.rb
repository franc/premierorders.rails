require 'db/seed_loader.rb'
require 'csv'

CSV.open("db/seed_data/Feb4_CustomerList.csv", "r") do |row|
  next if row[0] == 'Manager FName'
  fname, lname, tname, addr_1, city, state, zip, phone, fax, email, network = row

  begin
    user = User.find_by_email(email) || User.create(:first_name => fname, :last_name => lname, :email => email, :phone => phone, :fax => fax, :password => SeedLoader.random_password(10))
    addr = Address.find_by_address1_and_city(addr_1, city) || Address.create(:address1 => addr_1, :city => city, :state => state, :postal_code => zip)
    user.address_books.create(:user => user, :address => addr)
    user.roles << Role.find_by_name('franchisee')
    user.save
  rescue
    puts "Could not load user for row #{row.inspect}"
  end
end
