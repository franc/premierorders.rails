module PropertiesHelper
  def self.create_property(params)
    descriptor = Property.descriptors(Items.const_get(params[:descriptor_mod]))[params[:descriptor_id].to_i]
    property = descriptor.create_property(params[:name])
    params[:values].values.each do |v|
      property.property_values.create(
        :name => v[:name],
        :dvinci_id => v[:dvinci_id],
        :module_names => descriptor.module_names,
        :value_str => JSON.generate(v[:fields])
      )
    end

    property
  end
end
