require 'property.rb'
require 'properties_helper.rb'
require 'item_queries'
require 'items/door.rb'

class ItemsController < ApplicationController
  load_and_authorize_resource :except => [
    :search, 
    :add_component_form,
    :add_property_form,
    :add_property,
    :property_descriptors,
    :property_form_fragment,
    :component_association_types
  ]

  # GET /items
  def index
    if !params[:search].blank?
      @search = Item.search do 
        with(:type).equal_to(params[:type]) unless params[:type].blank?
        with(:category).equal_to(params[:category]) unless params[:category].blank?
        with(:in_catalog).equal_to(true) unless params[:in_catalog].blank?
        keywords(params[:search])
        paginate(:page => params[:page], :per_page => 50)
        order_by(:position)
      end 

      @items = @search.results
    else
      conditions = params.reject do |k, v|
        !['type', 'category'].include?(k) || v.blank?
      end

      @items = conditions.empty? ? @items : @items.where(conditions.to_hash)
      @items = @items.where(:in_catalog => true) unless params[:in_catalog].blank?
      @items = @items.order(:position, :name).paginate(:page => params[:page], :per_page => 50)
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def sorting
    authorize! :manage, Item
    @items = Item.where(:in_catalog => true).order(:position)

    respond_to do |format|
      format.html 
    end
  end

  def sort
    authorize! :manage, Item
    @items = Item.where(:in_catalog => true).order(:position)
    @items.each do |item|
      if position = params[:item_sorting].index(item.id.to_s)
        item.update_attribute(:position, position + 1) unless item.position == position + 1
      end
    end

    render :nothing => true, :status => 200
  end

  # GET /items/1
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /items/new
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    @item = Item.new(params[:item])
    @item.type = params[:item][:type]
    @property_associations = JSON.parse(params[:property_associations])

    respond_to do |format|
      if @item.save
        @property_associations.each do |key, qualifiers|
          property = Property.find(key)
          PropertiesHelper.create_item_properties(@item, property, qualifiers)
        end

        format.html { redirect_to(@item, :notice => 'Item was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /items/1
  def update
    if @item && params[:item][:type] 
      Item.execute_sql(["UPDATE items SET type = ? WHERE id = ?", params[:item][:type], @item.id]);
    end

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(item_path(@item), :notice => 'Item was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /items/1
  def destroy
    begin
      @item.destroy
    rescue 
      flash[:error] = "Item deletion failed! Please ensure that no jobs reference this item."
    end

    respond_to do |format|
      format.html { redirect_to(items_url) }
    end
  end

  def search
    @items = Item.simple_search(params[:types], params[:term])
    if request.xhr?
      render :json => @items.map{|item| item_select_json(item)}
    end
  end

  def item_select_json(item)
    {
      :label => item.name,
      :value => {
        :item_id => item.id,
        :item_name => item.name,
        :dvinci_id => item.dvinci_id,
        :properties => item.properties.map{|p| {:name => p.name, :family => p.family.titlecase}}
      }
    }
  end

  def properties
    if request.xhr?
      render :partial => 'properties', :locals => {
        :id => 'item_properties',
        :properties => @item.item_properties,
        :resource_path => lambda {|item_prop| item_property_path(item_prop)}
      }
    end
  end

  def components
    if request.xhr?
      render :partial => 'components', :locals => {
        :id => 'item_components',
        :item_components => @item.item_components
      }
    end
  end

  def add_component_form
    authorize! :create, ItemComponent
    render '_add_component', :layout => 'minimal'
  end

  def add_component
    if request.xhr?
      @component = Item.find_by_id(params[:component_id])
      association_type = Item.component_association_modules(@item.class).values.flatten[params[:association_id].to_i]
      quantity = params[:quantity]

      association = ItemComponent.new(:item_id => @item.id, :component_id => @component.id, :quantity => quantity)
      association.type = association_type.to_s
      association.save

      properties = params[:component_properties]
      unless properties.nil? 
        case properties[:type] 
          when "new" 
            property = PropertiesHelper.create_property(properties[:property])
            PropertiesHelper.create_item_component_properties(association, property, properties[:qualifiers])
          when "existing" 
            unless properties[:property_id].blank?
              PropertiesHelper.create_item_component_properties(association, Property.find(properties[:property_id]), properties[:qualifiers])
            end
        end
      end

      render :json => {:updated => 'success'}
    end
  end

  def add_property_form
    authorize! :create, Property

    render '_add_property', :layout => 'minimal', :locals => {
      :receiver_root => 'items',
      :include_submit => true
    }
  end

  def add_property
    authorize! :create, Property

    property = case params[:type]
      when "new"      then PropertiesHelper.create_property(params[:property])
      when "existing" then Property.find(params[:property_id])
    end    

    if params[:receiver_id]
      item = Item.find(params[:receiver_id])
      authorize! :update, item
      PropertiesHelper.create_item_properties(item, property, params[:qualifiers])
    end

    if request.xhr?
      render :json => PropertiesHelper.property_json(property)
    end
  end

  def property_descriptors
    if request.xhr?
      render :json => Property.descriptors(Items.const_get(params[:mod].demodulize)).to_json
    end
  end

  def property_form_fragment
    authorize! :create, Property

    descriptor_id = params[:id].to_i
    descriptor = Property.descriptors(Items.const_get(params[:mod].demodulize))[descriptor_id]

    render :partial => 'property_descriptor', :layout => false, :locals => {
      :descriptor => descriptor,
      :descriptor_id => descriptor_id
    }
  end
  
  def component_association_types
    type_map = Item.component_association_modules(Items.const_get(params[:mod].demodulize)).values.flatten.inject([]) do |result, cmod|
      result << { 
        :association_type => cmod.to_s.demodulize,
        :component_types  => ItemComponent.component_modules(cmod).map{|ct| ct.to_s.demodulize} 
      }
    end

    if request.xhr?
      render :json => type_map.to_json
    end
  end

  def pricing_expr
    query_context = ItemQueries::QueryContext.new(params)
    if request.xhr?
      render :json => {
        :retail_price_expr => @item.retail_price_expr(query_context).map{|e| e.compile}.orSome("No Pricing Data Available"),
        :cost_expr => @item.cost_expr(query_context).map{|e| e.compile}.orSome("No Pricing Data Available"),
        :components => component_exprs(query_context, @item)
      }
    end
  end

  def component_exprs(query_context, item)
    item.item_components.map{|c| {:name => c.component.name, :cost_expr => c.cost_expr(query_context).map{|e| e.compile}.orSome("No Pricing Data Available")}} + 
    item.item_components.map{|c| component_exprs(query_context, c.component)}.flatten
  end
end
