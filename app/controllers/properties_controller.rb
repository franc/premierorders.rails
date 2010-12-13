class PropertiesController < ApplicationController
  def search
    @properties = Property.search(params[:family], params[:term])

    if request.xhr?
    end
  end
end
