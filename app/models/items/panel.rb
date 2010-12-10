class Panel < Item
  include ItemMaterials

  def self.required_properties 
    PropertyDescriptor.new(:material, [], [Material])
  end

  # The panels associated with a shell will vary only with respect to width, length,
  # and color of material; all other possible dimensions will be fixed in the panel
  # instance.
  def calculate_price(width, length, color, units )
    material(color).price(length, width, units)
  end
end
