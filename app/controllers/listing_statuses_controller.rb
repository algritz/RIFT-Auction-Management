class ListingStatusesController < ApplicationController
  before_filter :authenticate_admin
  # GET /listing_statuses
  # GET /listing_statuses.xml
  def index
    @listing_statuses = ListingStatus.find(:all, :select => 'id, description, position, is_final', :order => 'description')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @listing_statuses }
    end
  end

  # GET /listing_statuses/1
  # GET /listing_statuses/1.xml
  def show
    @listing_status = ListingStatus.find(:first, :conditions => ["id = ?", params[:id]], :select => 'id, description, position, is_final', :order => 'description')
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @listing_status }
    end
  end

  # GET /listing_statuses/new
  # GET /listing_statuses/new.xml
  def new
    @listing_status = ListingStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @listing_status }
    end
  end

  # GET /listing_statuses/1/edit
  def edit
    @listing_status = ListingStatus.find(:first, :conditions => ["id = ?", params[:id]], :select => 'id, description, position, is_final', :order => 'description')
  end

  # POST /listing_statuses
  # POST /listing_statuses.xml
  def create
    @listing_status = ListingStatus.new(params[:listing_status])

    respond_to do |format|
      if @listing_status.save

        format.html { redirect_to(@listing_status, :notice => 'Listing status was successfully created.') }
        format.xml  { render :xml => @listing_status, :status => :created, :location => @listing_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @listing_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /listing_statuses/1
  # PUT /listing_statuses/1.xml
  def update
    @listing_status = ListingStatus.find(:first, :conditions => ["id = ?", params[:id]], :select => 'id, description, position, is_final', :order => 'description')
    ListingStatus.clear_cached(params[:id])
    ListingStatus.clear_cached_from_description(@listing_status.description)
    respond_to do |format|
      if @listing_status.update_attributes(params[:listing_status])

        format.html { redirect_to(@listing_status, :notice => 'Listing status was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @listing_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /listing_statuses/1
  # DELETE /listing_statuses/1.xml
  def destroy
    @listing_status = ListingStatus.find(:first, :conditions => ["id = ?", params[:id]], :select => 'id, description, position, is_final', :order => 'description')
    ListingStatus.clear_cached(params[:id])
    ListingStatus.clear_cached_from_description(@listing_status.description)
    @listing_status.destroy
    respond_to do |format|
      format.html { redirect_to(listing_statuses_url) }
      format.xml  { head :ok }
    end
  end

end
