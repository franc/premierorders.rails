require 'date'
require 'format_exception'

class JobsController < ApplicationController
  load_and_authorize_resource :except => [:create, :index, :dashboard]
  helper :production_batches
  helper :job_items

  # GET /jobs
  # GET /jobs.xml
  def index
    if !params[:search].blank?
      @search = Job.search do 
        with(:status).equal_to(params[:status]) unless params[:status].blank?
        without(:status).equal_to('Cancelled') if params[:status].blank?
        without(:status).equal_to('In Construction') if params[:status].blank?
        keywords(params[:search]) 
        order_by(:placement_date, :desc)
        paginate(:page => params[:page])
      end 

      @jobs = @search.results
    else
      conditions = params.reject do |k, v|
        !['status'].include?(k) || v.blank?
      end

      jobs_scope = conditions.empty? ? Job.where("status != 'Cancelled'") : Job.where(conditions.to_hash)
      @jobs = jobs_scope.where("status != 'In Construction'").order('jobs.placement_date DESC').select{|j| can?(:read, j)}.paginate(:page => params[:page], :per_page => 30)
    end

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

  def dashboard
    @jobs = Job.order('jobs.due_date DESC NULLS LAST, jobs.job_number NULLS LAST').select{|j| can? :read, j}

    @jobs_in_init = @jobs.select{|j| j.has_status?(*Job::STATUS_GROUPS[0])}
    @jobs_in_progress = @jobs.select{|j| j.has_status?(*Job::STATUS_GROUPS[1])}
    @jobs_in_ship = @jobs.select{|j| j.has_status?(*Job::STATUS_GROUPS[2])}

    respond_to do |format|
      format.html # dashboard.html.erb
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new
    @franchisees = if can? :pg_internal_cap, Job
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
    @franchisees = if can? :pg_internal_cap, Job
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
      @job.status = 'Created'
      @job.customer = current_user
      @job.primary_contact = current_user
      @job.source = 'dvinci'

      respond_to do |format|
        if @job.save
          File.open(@job.dvinci_xml.path) do |f|
            @job.add_items_from_dvinci(f)
          end
          @job.save

          @job.update_cached_values

          format.html { redirect_to(job_path(@job), :notice => 'Job was successfully created.') }
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
    prior_status = @job.status
    respond_to do |format|
      production_batch_id = params[:job].delete(:production_batch_id)
      if production_batch_id
        @production_batch = ProductionBatch.find_by_id(production_batch_id)
        @job.update_production_batch(@production_batch).cata( 
          lambda do |error|
            format.js   { render :json => {:updated => 'error', :error => error} }
            format.html { render :action => "edit" }
          end,
          lambda do |error|
            format.js   { render :json => {:updated => 'success'} }
            format.html { redirect_to(job_path(@job), :notice => 'Job was successfully updated.') }
          end
        )
      end

      sales_category = params[:job].delete(:sales_category)
      if sales_category
        @job.job_items.each do |job_item|
          job_item.update_attributes(:sales_category => sales_category)
        end
      end

      if @job.update_attributes(params[:job])
        if @job.status == 'Confirmed' && @job.status != prior_status
          OrderMailer.order_placed_email(@job).deliver
        end

        if @job.status != prior_status
          @job.job_state_transitions.create(
            :prior_status => prior_status,
            :new_status => @job.status,
            :changed_by => current_user
          )

          if @job.status == 'Shipped' 
            @job.ship_date ||= DateTime.now
            @job.save
            OrderMailer.order_shipped_email(@job).deliver
          end
        end
        
        format.html { redirect_to(job_path(@job), :notice => 'Job was successfully updated.') }
        format.js   do
          success_json = {:updated => 'success'} 
          success_json[:status_group_changed] = true if Job.status_group_changed?(prior_status, @job.status)
          render :json => success_json
        end
      else
        format.js   { render :json => {:updated => 'error'} }
        format.html { render :action => "edit" }
      end
    end
  end

  def recalculate
    @job.update_cached_values
    redirect_to :action => :show
  end

  def place_order
    @job.place_order(DateTime.now, current_user)
    respond_to do |format|
      if @job.save
        format.html { redirect_to(job_path(@job), :notice => 'Order was successfully placed.') }
      else
        format.html { redirect_to(job_path(@job), :error => "Order could not be placed: #{@job.errors}.") }
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
