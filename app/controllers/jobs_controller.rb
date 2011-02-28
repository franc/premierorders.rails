require 'date'
require 'job.rb'

class JobsController < ApplicationController
  load_and_authorize_resource :except => [:create, :index]
  helper :production_batches

  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = Job.order('jobs.created_at DESC NULLS LAST, jobs.due_date DESC NULLS LAST').select{|j| can? :read, j}.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new
    @franchisees = if can? :manage, Job
      Franchisee.order(:franchise_name)
    else
      current_user.franchisees.order(:franchise_name)
    end
    @addresses = @franchisees[0].nil? ? [] : @franchisees[0].addresses

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /jobs/1/edit
  def edit
    @franchisees = if can? :manage, @job
      Franchisee.order(:franchise_name)
    else
      current_user.franchisees.order(:franchise_name)
    end
    @addresses = @job.franchisee ? @job.franchisee.addresses : (@franchisees.nil? || @franchisees.empty? ? [] : @franchisees[0].addresses)
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    begin
      @job = Job.new(params[:job])
      @job.customer = current_user
      @job.primary_contact = current_user

      respond_to do |format|
        if @job.save
          File.open(@job.dvinci_xml.path) do |f|
            @job.add_items_from_dvinci(f)
          end
          @job.save
          format.html { redirect_to(@job, :notice => 'Job was successfully created.') }
        else
          format.html { render :action => "new" }
        end
      end
    rescue FormatException => ex
      flash[:error] = ex.message
      redirect_to :back
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @production_batch = ProductionBatch.find_by_id(params[:job][:production_batch_id])
    respond_to do |format|
      if params[:job].key?(:production_batch_id) 
        @job.update_production_batch(@production_batch).cata( 
          lambda do |error|
            format.js   { render :json => {:updated => 'error', :error => error} }
            format.html { render :action => "edit" }
          end,
          lambda do |error|
            format.js   { render :json => {:updated => 'success'} }
            format.html { redirect_to(@job, :notice => 'Job was successfully updated.') }
          end
        )
      elsif @job.update_attributes(params[:job])
        format.js   { render :json => {:updated => 'success'} }
        format.html { redirect_to(@job, :notice => 'Job was successfully updated.') }
      else
        format.js   { render :json => {:updated => 'error'} }
        format.html { render :action => "edit" }
      end
    end
  end

  def place_order
    @job.place_order(DateTime.now, current_user)
    respond_to do |format|
      if @job.save
        OrderPlacedMailer.order_placed_email(@job).deliver
        format.html { redirect_to(@job, :notice => 'Order was successfully placed.') }
      else
        format.html { redirect_to(@job, :error => "Order could not be placed: #{@job.errors}.") }
      end
    end
  end

  def cutrite
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def download
    send_data @job.to_cutrite_csv,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@job.job_number}.csv"
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
    end
  end
end
