require 'properties_helper.rb'

class ItemComponentsController < ApplicationController
  def edit
    @item_component = ItemComponent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  def destroy
    @component = ItemComponent.find(params[:id])
    @component.destroy
    
    if request.xhr?
      render :json => {:updated => 'success'}
    else
      respond_to do |format|
        format.html { redirect_to items_url }
        format.xml  { head :ok }
      end
    end
  end
  
  def add_property
    property = case params[:type]
      when "new"      then PropertiesHelper.create_property(params[:property])
      when "existing" then Property.find(params[:property_id])
    end    

    if params[:receiver_id]
      association = ItemComponent.find(params[:receiver_id])
      PropertiesHelper.create_item_component_properties(association, property, params[:qualifiers])
    end

    if request.xhr?
      render :json => PropertiesHelper.property_json(property)
    end
  end

  def add_property_form
    render 'items/_add_property', :layout => 'minimal', :locals => {
      :receiver_root => 'item_components',
      :include_submit => true
    }
  end

  def property_descriptors
    if request.xhr?
      render :json => Property.descriptors(Items.const_get(params[:mod])).to_json
    end
  end

  def property_form_fragment
    descriptor_id = params[:id].to_i
    descriptor = Property.descriptors(Items.const_get(params[:mod]))[descriptor_id]

    render :partial => 'items/property_descriptor', :layout => false, :locals => {
      :descriptor => descriptor,
      :descriptor_id => descriptor_id
    }
  end

  def properties
    if request.xhr?
      comp = ItemComponent.find(params[:id])
      render :partial => 'items/properties', :layout => false, :locals => {
        :id => 'component_relationship_properties',
        :properties => comp.item_component_properties,
        :resource_path => lambda {|icp| item_component_property_path(icp)}
      }
    end
  end
 end
