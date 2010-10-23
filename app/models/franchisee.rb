class Franchisee < ActiveRecord::Base
	has_many :users, :through => :franchisee_contacts
	has_one  :primary_contact, :class_name => 'User', :through => :franchisee_contacts, :conditions => "franchisee_contacts.contact_type = 'primary'"

	has_many :addresses, :through => :franchisee_addresses
	has_one  :shipping_address, :class_name => 'Address', :through => :franchisee_addresses, :conditions => "franchisee_addresses.address_type = 'shipping'"
end

