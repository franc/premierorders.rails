class Franchisee < ActiveRecord::Base
  has_many :franchisee_contacts
	has_many :users, :through => :franchisee_contacts
	has_one  :primary_contact, :class_name => 'FranchiseeContact',
           :conditions => {:contact_type => 'primary'}

  has_many :franchisee_addresses
	has_many :addresses, :through => :franchisee_addresses
	has_one  :billing_address, :class_name => 'FranchiseeAddress',
           :conditions => {:address_type => 'billing'}
	has_one  :shipping_address, :class_name => 'FranchiseeAddress',
           :conditions => {:address_type => 'shipping'}

  has_many :jobs
end

