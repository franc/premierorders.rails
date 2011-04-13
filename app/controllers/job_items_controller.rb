class JobItemsController < ApplicationController
  load_and_authorize_resource 
  
  # GET /job_items/1
  # GET /job_items/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job_item }
    end
  end

  # GET /job_items/new
  # GET /job_items/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job_item }
    end
  end

  # GET /job_items/1/edit
  def edit
  end

  # POST /job_items
  # POST /job_items.xml
  def create
    respond_to do |format|
      if @job_item.save
        format.html { redirect_to(@job_item, :notice => 'Job item was successfully created.') }
        format.xml  { render :xml => @job_item, :status => :created, :location => @job_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /job_items/1
  # PUT /job_items/1.xml
  def update
    respond_to do |format|
      if @job_item.update_attributes(params[:job_item])
        format.html { redirect_to(@job_item, :notice => 'Job item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def compute_unit_price
    computed_unit_price = @job_item.compute_unit_price
    respond_to do |format|
      format.js do
        render :json => computed_unit_price.map{|p| p.cata(
          lambda {|err| {:error => err}},
          lambda {|price| {:success => price}}
        )}.orSome(
          {:error => "Could not determine catalog item for job item #{@job_item.ingest_desc} (#{@job_item.ingest_id})"}
        )
      end
    end
  end

  # DELETE /job_items/1
  # DELETE /job_items/1.xml
  def destroy
    @job_item.destroy

    respond_to do |format|
      format.html { redirect_to(job_items_url) }
      format.xml  { head :ok }
    end
  end
end
