class User < ActiveRecord::Base
	has_many :addresses, :through => :address_book
	has_one  :shipping_address, :class_name => 'Address', :through => :address_book, :conditions => "address_books.address_type = 'shipping'"
end
