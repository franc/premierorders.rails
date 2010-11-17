class FranchiseesController < ApplicationController
  # GET /franchisees
  # GET /franchisees.xml
  def index
    @franchisees = Franchisee.order(:franchise_name).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @franchisees }
    end
  end

  # GET /franchisees/1
  # GET /franchisees/1.xml
  def show
    @franchisee = Franchisee.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @franchisee }
    end
  end

  # GET /franchisees/new
  # GET /franchisees/new.xml
  def new
    @franchisee = Franchisee.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @franchisee }
    end
  end

  # GET /franchisees/1/edit
  def edit
    @franchisee = Franchisee.find(params[:id])
  end

  # POST /franchisees
  # POST /franchisees.xml
  def create
    @franchisee = Franchisee.new(params[:franchisee])

    respond_to do |format|
      if @franchisee.save
        format.html { redirect_to(@franchisee, :notice => 'Franchisee was successfully created.') }
        format.xml  { render :xml => @franchisee, :status => :created, :location => @franchisee }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @franchisee.errors, :status => :unprocessable_entity }
      end
    end
  end

  def addresses
    @franchisee = Franchisee.find(params[:id])
    if request.xhr?
      address_options = @franchisee.addresses.inject({}) { |m, addr| m[addr.id] = addr.single_line; m }
      logger.info("About to render as JSON: #{address_options.inspect}")
      render :json => address_options
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @franchisee.addresses }
      end
    end
  end

  # PUT /franchisees/1
  # PUT /franchisees/1.xml
  def update
    @franchisee = Franchisee.find(params[:id])

    respond_to do |format|
      if @franchisee.update_attributes(params[:franchisee])
        format.html { redirect_to(@franchisee, :notice => 'Franchisee was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @franchisee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /franchisees/1
  # DELETE /franchisees/1.xml
  def destroy
    @franchisee = Franchisee.find(params[:id])
    @franchisee.destroy

    respond_to do |format|
      format.html { redirect_to(franchisees_url) }
      format.xml  { head :ok }
    end
  end
end
