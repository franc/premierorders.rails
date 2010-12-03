module ItemMaterials
    def material_attr
      item_attrs.find_by_type('Material')
    end

    def material(attributes)
      item_attr_options.find_all_by_item_attr_id(material_attr.id).find do |opt|
        (attributes[:color] ? material_attr.color(opt) == attributes[:color] : true) &&
        (attributes[:thickness] ? material_attr.thickness(opt) == attributes[:thickness] : true)
      end
    end
end
