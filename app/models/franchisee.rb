class Franchisee < ActiveRecord::Base
  has_many :franchisee_contacts
	has_many :users, :through => :franchisee_contacts
	has_one  :primary_contact, :class_name => 'User',
           :through => :franchisee_contacts,
           :source => :user,
           :conditions => "franchisee_contacts.contact_type = 'primary'"

  has_many :franchisee_addresses
	has_many :addresses, :through => :franchisee_addresses
	has_one  :shipping_address, :class_name => 'Address', 
           :through => :franchisee_addresses,
           :source => :address,
           :conditions => "franchisee_addresses.address_type = 'shipping'"
end

class FranchiseeAddress < ActiveRecord::Base
	belongs_to :franchisee
	belongs_to :address
end

class FranchiseeContact < ActiveRecord::Base
	belongs_to :franchisee
	belongs_to :user
end
