require 'property.rb'
require 'properties_helper.rb'
require 'items/door.rb'

class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    @items = Item.all.sort{|a, b| a.name <=> b.name}

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
    @item.type = params[:item][:type]
    @property_associations = JSON.parse(params[:property_associations])

    respond_to do |format|
      if @item.save
        @property_associations.each do |key, qualifiers|
          property = Property.find(key)
          PropertiesHelper.create_item_properties(@item, property, qualifiers)
        end

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
        format.html { redirect_to(item_path(@item), :notice => 'Item was successfully updated.') }
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
    @items = Item.search(params[:types], params[:term])
    logger.info @items.map{|item| item_select_json(item)}.inspect
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
      item = Item.find(params[:id])
      render :partial => 'properties', :layout => false, :locals => {
        :id => 'item_properties',
        :properties => item.item_properties,
        :resource_path => lambda {|item_prop| item_property_path(item_prop)}
      }
    end
  end

  def components
    if request.xhr?
      item = Item.find(params[:id])
      render :partial => 'components', :layout => false, :locals => {
        :id => 'item_components',
        :item_components => item.item_components
      }
    end
  end

  def add_component_form
    render '_add_component', :layout => 'minimal'
  end

  def add_component
    if request.xhr?
      receiver = Item.find_by_id(params[:id])
      component = Item.find_by_id(params[:component_id])
      association_type = Item.component_association_modules(receiver.class)[params[:association_id].to_i]
      quantity = params[:quantity]

      association = ItemComponent.new(:item_id => receiver.id, :component_id => component.id, :quantity => quantity)
      association.type = association_type.to_s
      association.save

      properties = params[:component_properties]
      unless properties.nil? || properties[:property_id].blank?
        property = case properties[:type] 
          when "new"      then PropertiesHelper.create_property(properties[:property])
          when "existing" then Property.find(properties[:property_id])
        end

        PropertiesHelper.create_item_component_properties(association, property, properties[:qualifiers])
      end

      render :json => {:updated => 'success'}
    end
  end

  def add_property_form
    render '_add_property', :layout => 'minimal', :locals => {
      :receiver_root => 'items',
      :include_submit => true
    }
  end

  def add_property
    property = case params[:type]
      when "new"      then PropertiesHelper.create_property(params[:property])
      when "existing" then Property.find(params[:property_id])
    end    

    if params[:receiver_id]
      item = Item.find(params[:receiver_id])
      PropertiesHelper.create_item_properties(item, property, params[:qualifiers])
    end

    if request.xhr?
      render :json => PropertiesHelper.property_json(property)
    end
  end

  def property_descriptors
    if request.xhr?
      render :json => Property.descriptors(Items.const_get(params[:mod])).to_json
    end
  end

  def property_form_fragment
    descriptor_id = params[:id].to_i
    descriptor = Property.descriptors(Items.const_get(params[:mod]))[descriptor_id]

    render :partial => 'property_descriptor', :layout => false, :locals => {
      :descriptor => descriptor,
      :descriptor_id => descriptor_id
    }
  end
  
  def component_types
    if request.xhr?
      render :json => Item.component_modules(Items.const_get(params[:mod])).to_json
    end
  end

  def component_association_types
    type_map = Item.component_association_modules(Items.const_get(params[:mod])).values.flatten.inject([]) do |result, cmod|
      result << { 
        :association_type => cmod.to_s.demodulize,
        :component_types  => Item.component_modules(cmod).map{|ct| ct.to_s.demodulize} 
      }
    end

    if request.xhr?
      render :json => type_map.to_json
    end
  end

  def pricing_expr
    @item = Item.find(params[:id])
    if request.xhr?
      render :json => {:expr => @item.pricing_expr(params[:units], params[:color])}
    end
  end
end
