class PropertiesController < ApplicationController
  def search
    @properties = Property.search(params[:family], params[:term])

    if request.xhr?
      render :json => @properties.map do |p|
        {
          :property_id => p.id,
          :property_name => p.name,
          :property_values => p.property_values.map do |v| 
            {:value_name => v.name, :data => v.extract}
          end
        }
      end
    end
  end
end
