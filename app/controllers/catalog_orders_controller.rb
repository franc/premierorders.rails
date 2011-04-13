class CatalogOrdersController < ApplicationController
  load_and_authorize_resource :except => [:catalog_json, :reference_data]
  
  # GET /catalog_orders
  def index
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
      :status => 'Created',
      :source => 'catalog'
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
    @items_data = Item.where(:in_catalog => true).order(:position).map do |item|
      sell_price = item.sell_price
      if sell_price.nil?
        sell_price = begin
          query_context = ItemQueries::QueryContext.new(:units => :in, :bulk => true)
          item.wholesale_price_expr(query_context).map{|expr| expr.evaluate({})}.orSome(item.base_price)
        rescue
          logger.error("Error calculating price for item: #{item.name}: #{$!}")
          logger.error($!.backtrace[0])
          item.base_price
        end
      end

      {
        :id => item.id,
        :name => item.name,
        :category => item.category,
        :purchase_part_id => item.purchase_part_id,
        :sell_price => sell_price,
        :ship_by => item.ship_by || 'standard',
        :position => item.position
      }
    end

    respond_to do |format|
      format.js { render :json => @items_data.to_json }
    end
  end

  def reference_data
    @franchisees = if can?(:manage, CatalogOrder) 
      Franchisee.order(:franchise_name) 
    else
      current_user.franchisees.order(:franchise_name)
    end

    respond_to do |format|
      format.js do
        render :json => @franchisees.inject({}) {|results, f|
          results[f.id] = {
            :name => f.franchise_name, 
            :users => f.users.order(:last_name, :first_name).map{|u| {:id => u.id, :name => u.name}},
            :addresses => f.addresses.map{|a| {:id => a.id, :single_line => a.single_line}}
          }

          results
        }
      end
    end
  end
end
