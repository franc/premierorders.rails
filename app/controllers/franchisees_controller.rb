class FranchiseesController < ApplicationController
  load_and_authorize_resource

  # GET /franchisees
  # GET /franchisees.xml
  def index
    @franchisees = @franchisees.order(:franchise_name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @franchisees }
    end
  end

  # GET /franchisees/1
  # GET /franchisees/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @franchisee }
    end
  end

  # GET /franchisees/new
  # GET /franchisees/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @franchisee }
    end
  end

  # GET /franchisees/1/edit
  def edit
  end

  # POST /franchisees
  # POST /franchisees.xml
  def create
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
    @address_options = @franchisee.addresses.inject({}) { |m, addr| m[addr.id] = addr.single_line; m }
    if request.xhr?
      render :json => @address_options
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @franchisee.addresses }
      end
    end
  end

  def create_address
    @address = Address.create(params[:address])
    @franchisee_address = @franchisee.franchisee_addresses.create(
      :address_type => params[:address_type],
      :address_id => @address.id
    )

    if request.xhr?
      render :partial => 'addresses', :locals => {:mode => nil}
    else
      redirect_to franchisee_url(@franchisee)
    end
 end

  # PUT /franchisees/1
  # PUT /franchisees/1.xml
  def update
    respond_to do |format|
      if @franchisee.update_attributes(params[:franchisee])
        if @franchisee.primary_contact.nil?
          @franchisee.franchisee_contacts.create(
            :contact_type => :primary, 
            :user_id => params[:primary_contact][:user_id].to_i
          )
        else
          @franchisee.primary_contact.user_id = params[:primary_contact][:user_id].to_i
          @franchisee.primary_contact.save
        end
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
    @franchisee.destroy
    respond_to do |format|
      format.html { redirect_to(franchisees_url) }
      format.xml  { head :ok }
    end
  end
end
