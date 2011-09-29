class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all, :select => "id, name, email, creation_code")

    respond_to do |format|
      if (is_admin?) then
        format.html # index.html.erb
        format.xml  { render :xml => @users }
      else
        format.html { redirect_to(signin_path, :notice => 'Only an admin can see all users') }
      end
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, name, email, creation_code")
    respond_to do |format|
      if (is_admin? || is_current_user?(@user.id)) then
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      else
        format.html { redirect_to(signin_path, :notice => 'You can only view yourself unless you are an admin')}
      end
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @creation_code = CreationCode.find(:first, :conditions => ["used = ?", false], :select => "id, creation_code, used")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, name, email, creation_code")
    @creation_code = CreationCode.find(:first, :conditions => ["creation_code = ?", @user.creation_code], :select => "id, creation_code")
    @creation_code == nil ? @creation_code = CreationCode.find(:first, :conditions => ["used = ?", false], :select => "id, creation_code, used"):@creation_code
    respond_to do |format|
      if (is_admin? || is_current_user?(@user.id)) then
      format.html # edit.html.erb
      else
        format.html { redirect_to(signin_path, :notice => 'You can only edit yourself unless you are an admin')}
      end
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @creation_code = CreationCode.find(:first, :conditions => ["creation_code = ?", @user.creation_code], :select => "id, creation_code")
    respond_to do |format|
      if @user.save
        @creation_code.used = true
        @creation_code.save

        format.html { redirect_to(signin_path, :notice => 'User was successfully created.') }
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
    @user = User.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, name, email, creation_code, salt, encrypted_password")
    @creation_code = CreationCode.find(:first, :conditions => ["creation_code = ?", @user.creation_code], :select => "id, creation_code")
    @creation_code == nil ? @creation_code = CreationCode.find(:first, :conditions => ["used = ?", false], :select => "id, creation_code, used"):@creation_code
    p  @creation_code
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @creation_code.used = true
        @creation_code.save

        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
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
    @user = User.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, name, email, is_admin, creation_code")
    if (is_admin? || is_current_user?(@user.id)) then
    @user.destroy

    end

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

end