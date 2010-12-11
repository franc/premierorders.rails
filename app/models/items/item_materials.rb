module ItemMaterials
  # retrieve the material property values by color.
  def material(descriptor, color)
    mprop = properties.find_by_descriptor(descriptor)
    mprop.property_values.detect{|v| v.color == color}
  end
end
