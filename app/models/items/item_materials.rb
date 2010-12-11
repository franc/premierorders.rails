module ItemMaterials
  def material_property(family)
    properties.find_by_family(family)
  end

  # retrieve the material property values by color.
  def material(family, color)
    mprop = material_property(family)
    mprop.property_values.detect{|prop| mprop.hydrate(prop).color == color}
  end
end
