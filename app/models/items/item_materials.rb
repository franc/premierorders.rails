module ItemMaterials
  def material_property
    properties.find_by_family(:panel_material)
  end

  # retrieve the material property values by color.
  def material(color)
    mprop = material_property
    mprop.property_values.detect{|prop| mprop.hydrate(prop).color == color}
  end
end
