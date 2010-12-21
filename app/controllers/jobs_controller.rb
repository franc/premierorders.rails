require 'date'
require 'job.rb'

class JobsController < ApplicationController
  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = Job.order(:due_date).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new
    @franchisees = Franchisee.find(:all)
    @addresses = @franchisees[0].nil? ? [] : @franchisees[0].addresses

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
    @franchisees = Franchisee.find(:all)
    @addresses = @franchisees[0].nil? ? [] : @franchisees[0].addresses
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    begin
      @job = Job.new(params[:job])

      respond_to do |format|
        if @job.save
          File.open(@job.dvinci_xml.path) do |f|
            @job.add_items_from_dvinci(f)
          end
          @job.save
          format.html { redirect_to(@job, :notice => 'Job was successfully created.') }
          format.xml  { render :xml => @job, :status => :created, :location => @job }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
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
    @job = Job.find(params[:id])

    if request.xhr?
      if @job.update_attributes(params[:job])
        render :json => {:updated => 'success'}
      else
        render :json => {:updated => 'error'}
      end
    else
      respond_to do |format|
        if @job.update_attributes(params[:job])
          format.html { redirect_to(@job, :notice => 'Job was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def cutrite
    @job = Job.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cutrite_data }
    end
  end

  def download
    job = Job.find(params[:id])
    d = DateTime.now
    send_data job.to_cutrite_csv,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{job.job_number}.csv"
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.xml  { head :ok }
    end
  end
end
