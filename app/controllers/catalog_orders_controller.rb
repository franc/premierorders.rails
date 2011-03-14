class CatalogOrdersController < ApplicationController
  # GET /catalog_orders/1
  # GET /catalog_orders/1.xml
  def show
    @catalog_order = CatalogOrder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def manifest
    text = <<-MANIFEST
      CACHE MANIFEST
      /catalog_orders/order_entry
      /stylesheets/scaffold.css
      /javascripts/jquery.js
      /javascripts/application.js
    MANIFEST

    send_data text.gsub(/^\s*/,''), :type => 'text/cache-manifest; charset=iso-8859-1; header=present'
  end

  def catalog_json
    @items_data = Item.where('category IS NOT NULL').map do |item|
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

  # GET /catalog_orders/order_entry
  def new
    @franchisees = can?(:manage, CatalogOrder) ?  Franchisee.order(:franchise_name) : current_user.franchisees.order(:franchise_name)
    @addresses = @franchisees[0].nil? ? [] : @franchisees[0].addresses

    respond_to do |format|
      format.html { render :action => "edit" }
    end
  end

  def create
    @job = CatalogOrder.create(
      :name => params[:name],
      :franchisee_id => params[:franchisee_id],
      :primary_contact_id => params[:primary_contact_id],
      :shipping_address_id => params[:shipping_address_id],
      :billing_address_id => params[:billing_address_id],
      :status => 'Placed'
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

  # GET /catalog_orders/1/edit
  def edit
    @items = Item.where('category IS NOT NULL')
    @catalog_order = CatalogOrder.find(params[:id])
  end

  # PUT /catalog_orders/1
  # PUT /catalog_orders/1.xml
  def update
    @catalog_order = CatalogOrder.find(params[:id])

    respond_to do |format|
      if @catalog_order.update_attributes(params[:catalog_order])
        format.html { redirect_to( job_path(@catalog_order), :notice => 'Catalog order was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /catalog_orders/1
  # DELETE /catalog_orders/1.xml
  def destroy
    @catalog_order = CatalogOrder.find(params[:id])
    @catalog_order.destroy

    respond_to do |format|
      format.html { redirect_to(catalog_orders_url) }
    end
  end
end
