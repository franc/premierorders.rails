class CatalogOrdersController < ApplicationController
  load_and_authorize_resource :except => [:catalog_data]
  
  # GET /catalog_orders
  def index
    @franchisees = can?(:manage, CatalogOrder) ?  Franchisee.order(:franchise_name) : current_user.franchisees.order(:franchise_name)
    @addresses = @franchisees[0].nil? ? [] : @franchisees[0].addresses

    respond_to do |format|
      format.html 
    end
  end

  def create
    @job = CatalogOrder.create(
      :name => params[:name],
      :franchisee_id => params[:franchisee_id],
      :primary_contact_id => params[:primary_contact_id],
      :shipping_address_id => params[:shipping_address_id],
      :billing_address_id => params[:billing_address_id],
      :status => 'Created'
    )
    
    respond_to do |format|
      if @job.save
        tracking_id = 0
        params[:quantities].each do |item_id, qty|
          item = Item.find(item_id)
          job_item = JobItem.create(
            :job_id => @job.id,
            :item_id => item.id,
            :quantity => qty,
            :unit_price => item.sell_price,
            :tracking_id => (tracking_id += 1)
          )

          job_item.update_cached_values
          job_item.save
        end

        format.js   { render :json => {:updated => 'success', :job_id => @job.id } }
        format.html { render :action => "jobs/show" }
      else
        format.js   { render :json => {:updated => :failure} }
        format.html { render :action => "edit" }
      end 
    end
  end

  def catalog_json
    @items_data = Item.where(:in_catalog => true).map do |item|
      {
        :id => item.id,
        :name => item.name,
        :category => item.category,
        :purchase_part_id => item.purchase_part_id,
        :sell_price => item.sell_price,
        :ship_by => item.ship_by || 'standard'
      }
    end

    respond_to do |format|
      format.js { render :json => @items_data.to_json }
    end
  end
end
