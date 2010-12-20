class PropertiesController < ApplicationController
  def create
    if request.xhr?
      property = PropertiesHelper.create_property(params)
      # go ahead and create the association to the item if data is provided
      item_id = params[:item_id]
      qualifiers = params[:qualifiers]
      if (item_id)
        item = Item.find_by_id(item_id)
        if (item) 
          if qualifiers.nil? || qualifiers.empty?
            ItemProperty.create(:item => item, :property => property)  
          else
            qualifiers.each do |q|
              ItemProperty.create(:item => item, :property => property, :qualifier => q)  
            end
          end
        end
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

    if request.xhr?
      render :json => property_json(@property)
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
      render :json => @properties.map{|p| property_json(p)}
    end
  end

  private 

  def property_json(p)
    {
      :label => p.name,
      :value => {
        :property_id => p.id,
        :property_name => p.name,
        :property_family => p.family,
        :property_values => p.property_values.map do |v| 
          {:value_name => v.name, :dvinci_id => (v.dvinci_id || ''), :data => JSON.parse(v.value_str)}
        end
      }
    }
  end
end
