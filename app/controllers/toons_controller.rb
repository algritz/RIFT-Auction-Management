class ToonsController < ApplicationController
  # GET /toons
  # GET /toons.xml
  def index
    @toons = Toon.all_cached_toon_for_user(current_user[:id])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @toons }
    end
  end

  # GET /toons/1
  # GET /toons/1.xml
  def show
    @toon = Toon.cached_toon(params[:id])

    respond_to do |format|
      if @toon.user_id == current_user[:id] then
        format.html # show.html.erb
        format.xml  { render :xml => @toon }
      else
        format.html {redirect_to(signin_path, :notice => 'You can only see your own toons')}
      end
    end
  end

  # GET /toons/new
  # GET /toons/new.xml
  def new
    @toon = Toon.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @toon }
    end
  end

  # GET /toons/1/edit
  def edit
    @toon = Toon.cached_toon(params[:id])
    respond_to do |format|
      if (is_admin? || is_current_user?(@toon.user_id) || @toon.id == nil ) then
      format.html # edit.html.erb
      else
        format.html { redirect_to(signin_path, :notice => 'You can only edit your own toon unless you are an admin')}
      end
    end
  end

  # POST /toons
  # POST /toons.xml
  def create
    @toon = Toon.new(params[:toon])
    Toon.clear_all_cached_toon_for_user(current_user[:id])
    respond_to do |format|
      if @toon.save

        format.html { redirect_to(@toon, :notice => 'Toon was successfully created.') }
        format.xml  { render :xml => @toon, :status => :created, :location => @toon }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @toon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /toons/1
  # PUT /toons/1.xml
  def update
    @toon = Toon.find(:first, :conditions=>["id = ?", params[:id]], :select => "id, name, user_id")
    Toon.clear_cached_toon(params[:id])
    Toon.clear_all_cached_toon_for_user(current_user[:id])
    respond_to do |format|
      if @toon.update_attributes(params[:toon])

        format.html { redirect_to(@toon, :notice => 'Toon was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @toon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /toons/1
  # DELETE /toons/1.xml
  def destroy
    @toon = Toon.cached_toon(params[:id])

    if (is_admin? || is_current_user?(@toon.id)) then
    Toon.clear_cached_toon(params[:id])
    Toon.clear_all_cached_toon_for_user(current_user[:id])
    @toon.destroy
    end

    respond_to do |format|
      format.html { redirect_to(toons_url) }
      format.xml  { head :ok }
    end
  end
end
