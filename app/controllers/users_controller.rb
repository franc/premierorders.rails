require 'util/option'

class UsersController < ApplicationController
  load_and_authorize_resource 
  
  # GET /users
  # GET /users.xml
  def index
    @users = @users.order(:last_name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.xml
  def create
    if can? :assign_role, @user
      @role_names = params[:user][:roles]
      @role_names.each do |name|
        Option.new(Role.find_by_name(name)).each do |role|
          @user.roles << role
        end
      end
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    if can? :assign_role, @user
      logger.info("Assigning roles #{params[:user][:roles]} to #{@user.first_name}")
      @user.roles.clear
      role_ids = params[:user][:roles]
      unless role_ids.nil?
        role_ids.each do |id|
          Option.new(Role.find_by_id(id)).each do |role|
            @user.roles << role
          end
        end
      end
    else
      logger.info("Can't set user roles.")
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(user_path(@user), :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
