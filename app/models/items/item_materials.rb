module ItemMaterials
    def material_property(name)
      properties.find_by_name_and_type(name, 'Material')
    end

    def material(name, attributes)
      mprop = material_property(name)
      mprop.property_values.select do |prop|
        (attributes[:color] ? mprop.color(prop) == attributes[:color] : true) &&
        (attributes[:thickness] ? mprop.thickness(prop) == attributes[:thickness] : true)
      end
    end
end
