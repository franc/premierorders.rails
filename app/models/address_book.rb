class AddressBook < ActiveRecord::Base
	belongs_to :address
	belongs_to :user
end
