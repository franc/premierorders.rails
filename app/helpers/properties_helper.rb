module PropertiesHelper
  def self.create_property(property_json)
    descriptor = Property.descriptors(Items.const_get(property_json[:descriptor_mod]))[property_json[:descriptor_id].to_i]
    property = descriptor.create_property(property_json[:name])

    property_json[:values].values.each do |v|
      property.property_values.create(
        :name => v[:name],
        :dvinci_id => v[:dvinci_id],
        :module_names => descriptor.module_names,
        :value_str => JSON.generate(v[:fields])
      )
    end

    property
  end

  def self.create_item_properties(item, property, qualifiers) 
    if item 
      if qualifiers.nil? || qualifiers.empty?
        ItemProperty.create(:item_id => item.id, :property_id => property.id)  
      else
        qualifiers.each do |q|
          ItemProperty.create(:item_id => item.id, :property_id => property.id, :qualifier => q)  
        end
      end
    end
  end

  def self.create_item_component_properties(association, property, qualifiers)
    if association
      if qualifiers.nil? || qualifiers.empty?
        ItemComponentProperty.create(:item_component_id => association.id, :property_id => property.id)
      else
        qualifiers.each do |q|
          ItemComponentProperty.create(:item_component_id => association.id, :property_id => property.id, :qualifier => q)
        end
      end
    end
  end
end

