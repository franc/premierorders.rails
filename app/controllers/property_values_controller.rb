class PropertyValuesController < ApplicationController
  load_and_authorize_resource 

  def destroy
    @property = Property.find(params[:property_id])

    @property.property_values.delete(@property_value)
    if @property_value.properties.empty?
      @property_value.destroy
    end

    respond_to do |format|
      format.js   { render :json => {:deleted => 'success'}}
      format.html { redirect_to(properties_url) }
      format.xml  { head :ok }
    end
  end
end
