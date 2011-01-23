class User < ActiveRecord::Base
  has_many :address_books, :dependent => :destroy
	has_many :addresses, :through => :address_books
	has_one  :shipping_address, :class_name => 'AddressBook', :conditions => {:address_type => 'shipping'}
  has_and_belongs_to_many :roles, :join_table => :user_roles
  has_many :franchisee_contacts, :dependent => :destroy
  has_many :franchisees, :through => :franchisee_contacts

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable, :registerable,
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :id, :title, :first_name, :last_name, :phone, :phone2, :fax,
                  :email, :password, :password_confirmation, :remember_me

  def role?(role)
    return !self.roles.find_by_name(role.to_s).nil?
  end
end
