class PropertiesController < ApplicationController
  def create
    if request.xhr?
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

      render :json => property_json(property)
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  def search
    @properties = Property.search(params[:family], params[:term])

    if request.xhr?
      render :json => @properties.map{|p| property_json(p)}
    end
  end

  def property_json(p)
    {
      :label => p.name,
      :value => {
        :property_id => p.id,
        :property_name => p.name.demodulize,
        :property_values => p.property_values.map do |v| 
          {:value_name => v.name, :data => JSON.parse(v.value_str)}
        end
      }
    }
  end
end
