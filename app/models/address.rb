class Address < ActiveRecord::Base
  def single_line
    "#{address1 + (address2 || '')}, #{city} #{state}, #{postal_code}"
  end
end
