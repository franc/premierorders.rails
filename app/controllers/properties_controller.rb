class PropertiesController < ApplicationController
  def create
    if request.xhr?
      @property = PropertiesHelper.create_property(params[:property])
      PropertiesHelper.create_item_properties(Item.find(params[:receiver_id]), @property, params[:qualifiers])

      render :json => PropertiesHelper.property_json(@property)
    else
      @property = Property.new(params[:property])
      respond_to do |format|
        if @property.save
          format.html { redirect_to(@property, :notice => 'Property was successfully created.') }
          format.xml  { render :xml => @property, :status => :created, :location => @property }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def show
    @property = Property.find(params[:id])

    if request.xhr?
      render :json => PropertiesHelper.property_json(@property)
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @item }
      end
    end
  end

  def search
    @properties = Property.search(params[:family], params[:term])

    if request.xhr?
      render :json => @properties.map{|p| {:label => p.name, :value => PropertiesHelper.property_json(p)}}
    end
  end
end
