require 'json'

class PropertiesController < ApplicationController
  load_and_authorize_resource :except => [:create, :search]

  # GET /properties
  # GET /properties.xml
  def index
    @properties = @properties.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @properties }
    end
  end

  # GET /properties/1
  # GET /properties/1.xml
  def show
    if request.xhr?
      render :json => PropertiesHelper.property_json(@property)
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @property }
      end
    end
  end

  # GET /properties/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @property }
    end
  end

  # POST /properties
  # POST /properties.xml
  def create
    if request.xhr?
      @property = PropertiesHelper.create_property(params[:property])
      authorize! :create, @property

      PropertiesHelper.create_item_properties(Item.find(params[:receiver_id]), @property, params[:qualifiers])

      render :json => PropertiesHelper.property_json(@property)
    else
      @property = Property.new(params[:property])
      authorize! :create, @property

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

  # PUT /properties/1
  # PUT /properties/1.xml
  def update
    params[:property_value].each do |k, v|
      if k == "new"
        v.each do |idx, v|
          pv = PropertyValue.create(
            :name => v[:name],
            :value_str => JSON.generate(v[:fields]),
            :module_names => @property.module_names
          )

          @property.property_values << pv
          @property.save
        end
      else
        pv = PropertyValue.find(k)
        pv.name = v[:name]
        pv.value_str = JSON.generate(v[:fields])
        pv.save
      end
    end

    respond_to do |format|
      if @property.update_attributes(params[:property])
        format.html { redirect_to(@property, :notice => 'Property was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.xml
  def destroy
    @property.destroy

    respond_to do |format|
      format.html { redirect_to(properties_url) }
      format.xml  { head :ok }
    end
  end

  def search
    @properties = Property.search(params[:family], params[:term])

    if request.xhr?
      render :json => @properties.map{|p| {:label => p.name, :value => PropertiesHelper.property_json(p)}}
    end
  end
end
