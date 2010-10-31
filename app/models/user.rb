class User < ActiveRecord::Base
	has_many :addresses, :through => :address_book
	has_one  :shipping_address, :class_name => 'AddressBook', :conditions => {:address_type => 'shipping'}

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable, :registerable,
  #devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :title, :first_name, :last_name, :phone, :phone2, :fax,
                  :email, :password, :password_confirmation, :remember_me
end
