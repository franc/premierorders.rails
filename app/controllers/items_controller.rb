class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    @items = Item.order(:name).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to(@item, :notice => 'Item was successfully created.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])

    if @item && params[:item][:type] 
      Item.execute_sql(["UPDATE items SET type = ? WHERE id = ?", params[:item][:type], @item.id]);
    end

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(@item, :notice => 'Item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end

  def search
    logger.info "Got types: #{params[:types].inspect}"
    @items = Item.search(params[:types], params[:term])

    if request.xhr?
      render :json => @items.map do |item|
        {
          :label => item.name,
          :value => {
            :item_id => item.id,
            :item_name => item.name,
            :dvinci_id => item.dvinci_id
          }
        }
      end
    end
  end

  def add_property_form
    render '_add_property', :layout => 'minimal'
  end

  def property_descriptors
    if request.xhr?
      render :json => Property.descriptors(Items.const_get(params[:mod])).to_json
    end
  end

  def property_form_fragment
    @descriptor = Property.descriptors(Items.const_get(params[:mod]))[params[:id].to_i]
    render '_property_descriptor'
  end
  
  def component_types
    if request.xhr?
      render :json => Item.component_types(Items.const_get(params[:mod])).to_json
    end
  end

  def component_association_types
    type_map = Item.component_association_modules(Items.const_get(params[:mod])).inject([]) do |result, cmod|
      result << { 
        :association_type => cmod.to_s.demodulize,
        :component_types  => component_types(cmod).map{|ct| ct.to_s.demodulize} 
      }
    end

    if request.xhr?
      render :json => type_map.to_json
    end
  end
end
