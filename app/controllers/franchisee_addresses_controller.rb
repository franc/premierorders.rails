class FranchiseeAddressesController < ApplicationController
  # GET /franchisee_addresses
  # GET /franchisee_addresses.xml
  def index
    @franchisee_addresses = FranchiseeAddress.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @franchisee_addresses }
    end
  end

  # GET /franchisee_addresses/1
  # GET /franchisee_addresses/1.xml
  def show
    @franchisee_address = FranchiseeAddress.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @franchisee_address }
    end
  end

  # GET /franchisee_addresses/new
  # GET /franchisee_addresses/new.xml
  def new
    @franchisee_address = FranchiseeAddress.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @franchisee_address }
    end
  end

  # GET /franchisee_addresses/1/edit
  def edit
    @franchisee_address = FranchiseeAddress.find(params[:id])
  end

  # POST /franchisee_addresses
  # POST /franchisee_addresses.xml
  def create
    @franchisee_address = FranchiseeAddress.new(params[:franchisee_address])

    respond_to do |format|
      if @franchisee_address.save
        format.html { redirect_to(@franchisee_address, :notice => 'Franchisee address was successfully created.') }
        format.xml  { render :xml => @franchisee_address, :status => :created, :location => @franchisee_address }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @franchisee_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /franchisee_addresses/1
  # PUT /franchisee_addresses/1.xml
  def update
    @franchisee_address = FranchiseeAddress.find(params[:id])

    respond_to do |format|
      if @franchisee_address.update_attributes(params[:franchisee_address])
        format.html { redirect_to(@franchisee_address, :notice => 'Franchisee address was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @franchisee_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /franchisee_addresses/1
  # DELETE /franchisee_addresses/1.xml
  def destroy
    @franchisee_address = FranchiseeAddress.find(params[:id])
    @franchisee_address.destroy

    respond_to do |format|
      format.html { redirect_to(franchisee_addresses_url) }
      format.xml  { head :ok }
    end
  end
end
