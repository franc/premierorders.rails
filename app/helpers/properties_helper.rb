require 'json'

module PropertiesHelper
  def self.create_property(property_json)
    descriptor = Property.descriptors(Items.const_get(property_json[:descriptor_mod].demodulize))[property_json[:descriptor_id].to_i]
    property = descriptor.create_property(property_json[:name])

    property_json[:values].values.each do |v|
      property.create_value(v[:name], v[:fields])
    end

    property
  end

  def self.create_item_properties(item, property, qualifiers) 
    if item && property
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
    if association && property
      if qualifiers.nil? || qualifiers.empty?
        ItemComponentProperty.create(:item_component_id => association.id, :property_id => property.id)
      else
        qualifiers.each do |q|
          ItemComponentProperty.create(:item_component_id => association.id, :property_id => property.id, :qualifier => q)
        end
      end
    end
  end

  def self.property_json(p)
    {
      :property_id => p.id,
      :property_name => p.name,
      :property_family => p.family,
      :property_values => p.property_values.map do |v| 
        {:value_name => v.name, :fields => JSON.parse(v.value_str)}
      end
    }
  end
end

