class SalesListingsController < ApplicationController
  # GET /sales_listings
  # GET /sales_listings.xml
  def index

    if params[:status] != nil then
      @sales_listings = SalesListing.joins('left join items on items.id = sales_listings.item_id').paginate(:page => params[:page],
      :order => "description",
      :conditions => "listing_status_id = #{params[:status]}")
    else if params[:search] != nil then
        @search = SalesListing.search(params[:search])
        @sales_listings = @search.paginate(:page => params[:page])
      else
        @sales_listings = SalesListing.joins('left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id').paginate(:page => params[:page],
        :order => "position, item_id")
      end
    end
    @status_list = ListingStatus.find(:all,
    :select => 'id, description',
    :order => 'position')
    @items = Item.find(:all,
    :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id',
    :order => 'description')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sales_listings }
    end
  end

  # GET /sales_listings/1
  # GET /sales_listings/1.xml
  def show
    @sales_listing = SalesListing.find(params[:id])
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :order => 'description')
    @listing_statuses = ListingStatus.find(:all, :select => 'id, description', :order => 'description')
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sales_listing }
    end
  end

  # GET /sales_listings/new
  # GET /sales_listings/new.xml
  def new
    @sales_listing = SalesListing.new
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> "to_list = 't'", :order => 'description')
    @listing_statuses = ListingStatus.find(:all, :select => 'id, description', :order => 'description')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sales_listing }
      format.js {p params}
    end
  end

  # GET /sales_listings/1/edit
  def edit
    @sales_listing = SalesListing.find(params[:id])
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :order => 'description')
    @listing_statuses = ListingStatus.find(:all, :select => 'id, description', :order => 'description')
  end

  # POST /sales_listings
  # POST /sales_listings.xml
  def create
    @sales_listing = SalesListing.new(params[:sales_listing])
    @listing_statuses = ListingStatus.find(:all, :select => 'id, description', :order => 'description')
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> "to_list = 't'", :order => 'source_id, description')
    respond_to do |format|
      if @sales_listing.save
        format.html { redirect_to(@sales_listing, :notice => 'Sales listing was successfully created.') }
        format.xml  { render :xml => @sales_listing, :status => :created, :location => @sales_listing }
      format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      format.js
      end
    end
  end

  # PUT /sales_listings/1
  # PUT /sales_listings/1.xml
  def update
    @sales_listing = SalesListing.find(params[:id])
    @listing_statuses = ListingStatus.find(:all, :select => 'id, description', :order => 'description')
    @expired_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Expired'")
    @inventory_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'In Inventory'")
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> "to_list = 't'", :order => 'source_id, description').first
    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])
        params[:sales_listing].each do |key, value|
          if key == "listing_status_id" then
            if value.to_i ==  @expired_listing.first.id then
              if @sales_listing.relisted_status != true then
                @sales_relisting = SalesListing.new(params[:sales_listing])
              @sales_relisting.listing_status_id = @inventory_listing.first.id
              @sales_listing.relisted_status = true
              @sales_listing.save
              @sales_relisting.save
              end
            end
          end

        end
        format.html { redirect_to(@sales_listing, :notice => 'Sales listing was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_listings/1
  # DELETE /sales_listings/1.xml
  def destroy
    @sales_listing = SalesListing.find(params[:id])
    @sales_listing.destroy

    respond_to do |format|
      format.html { redirect_to(sales_listings_url) }
      format.xml  { head :ok }
    end
  end

  def sold
    @sales_listing = SalesListing.find(params[:id])
    @sold_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Sold'")
    @sales_listing.listing_status_id = @sold_listing.first.id
    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])
        format.html { redirect_to(@sales_listing, :notice => 'Sales listing was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end
  end

  def expired
    @sales_listing = SalesListing.find(params[:id])
    @expired_listing = ListingStatus.find(:all,
    :select => 'id, description',
    :conditions => "description = 'Expired'")
    @inventory_listing = ListingStatus.find(:all,
    :select => 'id, description',
    :conditions => "description = 'In Inventory'")
    if @sales_listing.relisted_status != true then
      @sales_relisting = SalesListing.new(:item_id => @sales_listing.item_id,
      :stacksize => @sales_listing.stacksize,
      :deposit_cost => @sales_listing.deposit_cost,
      :listing_status_id => @inventory_listing.first.id,
      :price => @sales_listing.price,
      :is_undercut_price => @sales_listing.is_undercut_price)
    @sales_listing.listing_status_id = @expired_listing.first.id
    @sales_listing.relisted_status = true
    @sales_listing.save
    @sales_relisting.save
    end

    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])
        format.html { redirect_to(@sales_listing, :notice => 'Sales listing was successfully updated.') }
        format.xml  { head :ok }

      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end
  end

  def crafted
    @crafted_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Crafted'")
    @sales_listing = SalesListing.create!(:item_id => params[:id], :is_undercut => false,  :deposit_cost => lastDepositCost(params[:id]), :stacksize => 1, :listing_status_id => @crafted_listing.first.id, :price => lastSalesPrice(params[:id]))
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> "to_list = 't'", :order => 'source_id, description').first

    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])
        format.html { redirect_to(@sales_listing, :notice => 'Sales listing was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end
  end

  def mailed
    @mailed_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Mailed'")
    @sales_listing = SalesListing.find(params[:id])
    @sales_listing.listing_status_id = @mailed_listing.first.id
    @sales_listing.save
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> "to_list = 't'", :order => 'source_id, description').first

    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])
        format.html { redirect_to(@sales_listing, :notice => 'Sales listing was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end
  end

  ## -- start of private block -- ##
  private

  # this method is also present in application_helper, so any bug found
  # in this block is likely to happen over there
  def lastSalesPrice(id)
    if id != nil then
      sold_status = ListingStatus.find(:all, :conditions => "description ='Sold'").first
      expired = ListingStatus.find(:all, :conditions => "description ='Expired'").first
      sql_str = "listing_status_id = #{sold_status.id} and item_id = #{id} and is_undercut_price = 'f'"
      sql_expired_str = "listing_status_id = #{expired.id} and item_id = #{id} and is_undercut_price = 'f'"
      sold = SalesListing.find(:all, :conditions => sql_str).last
      expired = SalesListing.find(:all, :conditions => sql_expired_str).last
      if sold != nil then
        sold_id = sold.id
        price = SalesListing.find(sold_id).price
      else if expired != nil then
          expired_id = expired.id
          price = SalesListing.find(expired_id).price
        else
        price = 0
        end
      end
    end
  end

  def lastDepositCost(id)
    if id != nil then
      SalesListing.find(id, :select => 'deposit_cost').deposit_cost
    end
  end

## -- private block
end
