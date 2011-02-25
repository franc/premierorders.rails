class ProductionBatchesController < ApplicationController
  load_and_authorize_resource

  # GET /production_batches
  # GET /production_batches.xml
  def index
    @production_batches = ProductionBatch.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @production_batches }
    end
  end

  # GET /production_batches/1
  # GET /production_batches/1.xml
  def show
    @production_batch = ProductionBatch.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @production_batch }
    end
  end

  # GET /production_batches/new
  # GET /production_batches/new.xml
  def new
    @production_batch = ProductionBatch.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @production_batch }
    end
  end

  # GET /production_batches/1/edit
  def edit
    @production_batch = ProductionBatch.find(params[:id])
  end

  # POST /production_batches
  # POST /production_batches.xml
  def create
    @production_batch = ProductionBatch.new(params[:production_batch])

    respond_to do |format|
      if @production_batch.save
        format.html { redirect_to production_batches_path }
        format.xml  { render :xml => @production_batch, :status => :created, :location => @production_batch }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @production_batch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /production_batches/1
  # PUT /production_batches/1.xml
  def update
    @production_batch = ProductionBatch.find(params[:id])

    respond_to do |format|
      if @production_batch.update_attributes(params[:production_batch])
        format.html { redirect_to production_batches_patch }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @production_batch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /production_batches/1
  # DELETE /production_batches/1.xml
  def destroy
    @production_batch.destroy

    respond_to do |format|
      format.html { redirect_to(production_batches_url) }
      format.xml  { head :ok }
    end
  end

  def add_job
    @production_batch.add_job(Job.find(params[:job_id]))

    respond_to do |format|
      if @production_batch.save
        format.js   { render :json => {:updated => 'success'} }
        format.html { redirect_to(production_batches_url) }
        format.xml  { head :ok }
      else
        format.js   { render :json => {:updated => 'error', :errors => @production_batch.errors.to_json} }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @production_batch.errors, :status => :unprocessable_entity }
      end
    end
  end

  def cutrite
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @production_batch.to_cutrite_data }
    end
  end

  def download
    send_data @production_batch.to_cutrite_csv,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@production_batch.batch_no}.csv"
  end
end
