class Address < ActiveRecord::Base
  def single_line
    "#{address1 + (address2 || '')}, #{city} #{state}, #{postal_code}"
  end

  def same_as(other)
    (address1 || '').strip.casecmp((other.address1 || '').strip) == 0 &&
    (city || '').strip.casecmp((other.city || '').strip) == 0 &&
    (postal_code || '').strip.casecmp((other.postal_code || '').strip) == 0
  end
end
