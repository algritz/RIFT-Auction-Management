class SalesListingsController < ApplicationController
  before_filter :authenticate
  # GET /sales_listings
  # GET /sales_listings.xml
  def index
    if params[:status] != nil then
      if params[:status] != "0" then
        @sales_listings = SalesListing.joins("left join items on items.id = sales_listings.item_id").paginate(:page => params[:page],
        :order => "items.description, sales_listings.updated_at desc",
        :conditions => ["listing_status_id = ? and user_id = ?", params[:status], current_user[:id]])
      else
        @sales_listings = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").joins("left join items on items.id = sales_listings.item_id").paginate(:page => params[:page],
        :order => "position, items.description, sales_listings.updated_at desc",
        :conditions => ["user_id = ?", current_user[:id]])
      end
    else if params[:search] != nil then
        if params[:every_listings] == nil then
          @sales_listings = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").joins("left join items on items.id = sales_listings.item_id").where(["user_id = ? and listing_statuses.description = ?", current_user[:id], "Ongoing"]).search(params[:search], params[:page])
        else
          @sales_listings = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").joins("left join items on items.id = sales_listings.item_id").where(["user_id = ?", current_user[:id]]).search(params[:search], params[:page])
        end
      else
      # Using all_cached provides better performance while paging records, displaying the main page provides similar results though
      @sales_listings = SalesListing.all_cached(current_user[:id]).paginate(:page => params[:page])
      end
    end
    # using uncached results provide better performance, might be due to smaller data set
    @status_list = ListingStatus.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sales_listings }
    end
  end

  # GET /sales_listings/1
  # GET /sales_listings/1.xml
  def show
    #using cached results provide similar performance so we use cache in order to limit DB I/O
    @sales_listing = SalesListing.cached_saleslisting(params[:id])
    @items = Item.all_cached_item
    # using uncached results provide better performance, might be due to smaller data set
    @listing_statuses = ListingStatus.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      if @sales_listing.user_id == current_user[:id] then
        format.html # show.html.erb
        format.xml  { render :xml => @sales_listing }
      else
        format.html { redirect_to(signin_path, :notice => 'You can only view your own listings') }
      end
    end
  end

  # GET /sales_listings/new
  # GET /sales_listings/new.xml
  def new
    @sales_listing = SalesListing.new

    @items = Item.all_cached_item_to_list

    @item_details = Item.cached_item(params[:item_id])

    # using uncached results provide better performance, might be due to smaller data set
    @listing_statuses = ListingStatus.find(:all, :select => "id, description", :order => "description")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sales_listing }
      if request.xhr? then
      format.js
      end
    end
  end

  # GET /sales_listings/1/edit
  def edit
    @sales_listing = SalesListing.cached_saleslisting(params[:id])
    @item_details = Item.cached_item(@sales_listing.item_id)
    # using uncached results provide better performance, might be due to smaller data set
    @listing_statuses = ListingStatus.find(:all, :select => "id, description", :order => "description")

    respond_to do |format|
      if @sales_listing.user_id == current_user[:id] then
        format.html # show.html.erb
        format.xml  { render :xml => @sales_listing }
      else
        format.html { redirect_to(signin_path, :notice => 'You can only edit your own listings') }
      end
    end

  end

  # POST /sales_listings
  # POST /sales_listings.xml
  def create
    @sales_listing = SalesListing.new(params[:sales_listing])

    # using uncached results provide better performance, might be due to smaller data set
    @listing_statuses = ListingStatus.find(:all, :select => "id, description", :order => "description")
    @items = Item.all_cached_item_to_list
    # Cache clearing block: item_id, user_id, listing_id
    SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(nil, nil, params[:id])
    respond_to do |format|
      if @sales_listing.save
        format.html { redirect_to(sales_listings_path, :notice => 'Sales listing was successfully created.') }
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
    # cannot use cached result, as data set is read-only
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
    @listing_statuses = ListingStatus.cached_all_listing_status
    @expired_listing = ListingStatus.cached_listing_status_from_description('Expired')
    @inventory_listing = ListingStatus.cached_listing_status_from_description('In Inventory')
    @sold_listing = ListingStatus.cached_listing_status_from_description('Sold')

    @items = Item.all_cached_item_to_list
    # Cache clearing block: item_id, user_id, listing_id
    SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(nil, nil, params[:id])
    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])

        params[:sales_listing].each do |key, value|
          if key == "listing_status_id" then
            if value.to_i ==  @expired_listing[:id] then
              if @sales_listing.relisted_status != true then
              @sales_relisting = SalesListing.new(:item_id => @sales_listing.item_id,
              :stacksize => @sales_listing.stacksize,
              :deposit_cost => @sales_listing.deposit_cost,
              :listing_status_id => @inventory_listing[:id],
              :price => lastSalesPrice(@sales_listing.item_id),
              :is_undercut_price => @sales_listing.is_undercut_price,
              :user_id => current_user[:id])
              @sales_relisting.listing_status_id = @inventory_listing[:id]
              @sales_listing.relisted_status = true
              @sales_listing.save
              @sales_relisting.save
              end
            else if value.to_i ==  @sold_listing[:id] then
              @sales_listing.profit = calculateProfit(params[:id])
              @sales_listing.save
              end
            end
          end

        end
        format.html { redirect_to(sales_listings_path, :notice => 'Sales listing was successfully updated.') }
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
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, item_id")
    if (is_current_user?(@sales_listing.user_id)) then
    # Cache clearing block: item_id, user_id, listing_id
    SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(nil, nil, params[:id])
    @sales_listing.destroy
    end

    respond_to do |format|
      format.html { redirect_to(sales_listings_url) }
      format.xml  { head :ok }
    end
  end

  def sold
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price")

    if @sales_listing.user_id == @current_user[:id] then

      @sold_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'Sold'])

      @sales_listing.profit = calculateProfit(params[:id])
      @sales_listing.listing_status_id = @sold_listing.first.id
      @sales_listing.user_id = current_user[:id]
      # Cache clearing block: item_id, user_id, listing_id
      SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(nil, nil, params[:id])
      respond_to do |format|
        if @sales_listing.update_attributes(params[:sales_listing])

          format.html {
            if params[:search] != nil then
              if params[:every_listings] != nil then
              redirect_to(sales_listings_path+"?search="+params[:search]+"&every_listings="+params[:every_listings], :notice => 'Sales listing was successfully updated.')
              else
              redirect_to(sales_listings_path+"?search="+params[:search], :notice => 'Sales listing was successfully updated.')
              end
            else
            redirect_to(sales_listings_path, :notice => 'Sales listing was successfully updated.')
            end
          }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
        end
      end
    else
    redirect_to(signin_path, :notice => 'You can only edit your own sales listings')
    end
  end

  def expired
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")

    if @sales_listing.user_id == @current_user[:id] then

      @expired_listing = ListingStatus.find(:all,
      :select => 'id, description',
      :conditions => ["description = ?", 'Expired'])
      @inventory_listing = ListingStatus.find(:all,
      :select => 'id, description',
      :conditions => ["description = ?", 'In Inventory'])
      if @sales_listing.relisted_status != true then

      @sales_relisting = SalesListing.new(:item_id => @sales_listing.item_id,
      :stacksize => @sales_listing.stacksize,
      :deposit_cost => @sales_listing.deposit_cost,
      :listing_status_id => @inventory_listing.first.id,
      :price => lastSalesPrice(@sales_listing.item_id),
      :is_undercut_price => lastIsUndercutPrice(@sales_listing),
      :user_id => current_user[:id])

      @sales_listing.listing_status_id = @expired_listing.first.id
      @sales_listing.relisted_status = true
      @sales_listing.save
      @sales_relisting.save
      end
      # Cache clearing block: item_id, user_id, listing_id
      SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(nil, nil, params[:id])
      respond_to do |format|
        if @sales_listing.update_attributes(params[:sales_listing])

          format.html {
            if params[:search] != nil then
              if params[:every_listings] != nil then
              redirect_to(sales_listings_path+"?search="+params[:search]+"&every_listings="+params[:every_listings], :notice => 'Sales listing was successfully updated.')
              else
              redirect_to(sales_listings_path+"?search="+params[:search], :notice => 'Sales listing was successfully updated.')
              end
            else
            redirect_to(sales_listings_path, :notice => 'Sales listing was successfully updated.')
            end
          }
          format.xml  { head :ok }

        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
        end
      end
    else
    redirect_to(signin_path, :notice => 'You can only edit your own sales listings')
    end
  end

  def crafted
    @crafted_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'Crafted'])
    @sales_listing = SalesListing.create!(:item_id => params[:id], :is_undercut_price => lastIsUndercutPrice(params[:id]),  :deposit_cost => lastDepositCost(params[:id]), :stacksize => 1, :user_id => current_user[:id], :listing_status_id => @crafted_listing.first.id, :price => lastSalesPrice(params[:id]))

    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description').first
    Item.clear_cached_item_source_description(params[:id])
    # Cache clearing block: item_id, user_id, listing_id
    SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(nil, nil, params[:id])
    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])

        format.html {
          if params[:param] != nil then
            if params[:search] == nil then
            redirect_to(page_items_to_craft_path+"?param="+params[:param], :notice => 'Sales listing was successfully updated.')
            else
            redirect_to(page_items_to_craft_path+"?param="+params[:param]+"&search="+params[:search], :notice => 'Sales listing was successfully updated.')
            end
          else
            if params[:search] == nil then
            redirect_to(page_items_to_craft_path, :notice => 'Sales listing was successfully updated.')
            else
            redirect_to(page_items_to_craft_path+"?search="+params[:search], :notice => 'Sales listing was successfully updated.')
            end
          end
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end
  end

  def mailed
    @mailed_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'Mailed'])
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, item_id, stacksize, deposit_cost, price, user_id, listing_status_id")
    if @sales_listing.user_id == @current_user[:id] then

      @sales_listing.listing_status_id = @mailed_listing.first.id
      @sales_listing.save
      @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description').first
      # Cache clearing block: item_id, user_id, listing_id
      SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(nil, nil, params[:id])
      respond_to do |format|
        if @sales_listing.update_attributes(params[:sales_listing] && (is_admin? || is_current_user?(@user)))

          format.html { redirect_to(@sales_listing, :notice => 'Sales listing was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
        end
      end
    else
    redirect_to(signin_path, :notice => 'You can only edit your own sales listings')
    end
  end

  def in_inventory
    @inventory_listing = ListingStatus.cached_listing_status_from_description('In Inventory')
    @in_bank = ListingStatus.cached_listing_status_from_description('In Bank')
    @sales_listing = SalesListing.first(:select => "id, stacksize, listing_status_id, is_undercut_price, deposit_cost, price, item_id", :conditions => ["item_id = ? and user_id = ? and listing_status_id = ?", params[:id], @current_user[:id], @in_bank])

    if @sales_listing.stacksize == 1 then
    @sales_listing.listing_status_id = @inventory_listing[:id]
    @sales_listing.is_undercut_price = lastIsUndercutPrice(params[:id])
    @sales_listing.deposit_cost = lastDepositCost(params[:id])
    @sales_listing.price = lastSalesPrice(params[:id])
    else
    @sales_relisting = SalesListing.create!(:item_id => params[:id], :is_undercut => lastIsUndercutPrice(params[:id]),  :deposit_cost => lastDepositCost(params[:id]), :stacksize => 1, :user_id => current_user[:id], :listing_status_id => @inventory_listing[:id], :price => lastSalesPrice(params[:id]))
    @sales_listing.stacksize = @sales_listing.stacksize - 1
    @sales_relisting.save
    end
    @sales_listing.save
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description').first
    # Cache clearing block: item_id, user_id, listing_id
    SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
    SalesListing.clear_saleslisting_block(nil, nil, params[:id])
    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing] && (is_admin? || is_current_user?(@user)))

        format.html { redirect_to(page_items_to_list_from_bank_path, :notice => 'Sales listing was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end

  end

  def relist
    # using direct call to database since cached data is read-only
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")

    if @sales_listing.user_id == @current_user[:id] then
      @ongoing_listing = ListingStatus.cached_listing_status_from_description('Ongoing')

      @sales_listing.listing_status_id = @ongoing_listing[:id]

      # Cache clearing block: item_id, user_id, listing_id
      SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(@sales_listing.item_id, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(nil, nil, params[:id])
      respond_to do |format|
        if @sales_listing.update_attributes(params[:sales_listing])

          format.html {
            if params[:search] != nil then
              if params[:every_listings] != nil then
              redirect_to(sales_listings_path+"?search="+params[:search]+"&every_listings="+params[:every_listings], :notice => 'Sales listing was successfully updated.')
              else
              redirect_to(sales_listings_path+"?search="+params[:search], :notice => 'Sales listing was successfully updated.')
              end
            else
            redirect_to(sales_listings_path, :notice => 'Sales listing was successfully updated.')
            end
          }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
        end
      end
    else
    redirect_to(signin_path, :notice => 'You can only edit your own sales listings')
    end
  end

  ## -- start of private block -- ##
  private

  # this method is also present in application_helper, so any bug found
  # in this block is likely to happen over there
  def lastSalesPrice(item_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description('Sold')
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold = SalesListing.cached_last_sold_auction(sold_status[:id], item_id, current_user.id)
      last_sold_date = SalesListing.cached_last_sold_date(sold_status[:id], item_id, current_user.id)
      expired_listing = SalesListing.cached_expired_listing(expired_status[:id], item_id, current_user.id)

      if sold != nil then
        if (sold.updated_at == last_sold_date.updated_at) then
        price = (sold.price * 1.1).round
        else
        price = sold.price
        end
      else if expired_listing != nil then
          if last_sold_date != nil then
          @number_of_expired = SalesListing.cached_expired_count(expired_status[:id], item_id, current_user.id, last_sold_date.updated_at)
          else
          @number_of_expired = SalesListing.cached_expired_count_overall(expired_status[:id], item_id, current_user.id)

          end
          if @number_of_expired.modulo(5) == 0 then
          price = (expired_listing.price * 0.97).round
          else
          price = expired_listing.price
          end
        else
          listed_but_not_sold = SalesListing.cached_listed_but_not_sold(expired_status[:id], item_id, current_user.id)
          if listed_but_not_sold != nil then
          price = listed_but_not_sold.price
          else
          price = 0
          end
        end
      end
    end
  end

  def lastDepositCost(item_id)
    if item_id != nil then
      SalesListing.maximum('deposit_cost', :conditions => ["item_id = ? and user_id = ?", item_id, current_user[:id]]).to_i
    end
  end

  # this method is also present in the application helper, so any bug found there is likely to happen here
  def lastIsUndercutPrice(item_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description("Sold")
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold_not_undercut = SalesListing.cached_sold_not_undercut_count(item_id, current_user.id, sold_status[:id])
      expired_not_undercut = SalesListing.cached_expired_not_undercut_count(item_id, current_user.id, expired_status[:id])
      sold_and_undercut = SalesListing.cached_sold_and_undercut_count(item_id, current_user.id, sold_status[:id])
      expired_and_undercut = SalesListing.cached_expired_and_undercut_count(item_id, current_user.id, expired_status[:id])

      if sold_not_undercut > 0 then
      is_undercut_price = false
      else if expired_not_undercut > 0 then
        is_undercut_price = false
        else if sold_and_undercut > 0 then
          is_undercut_price = true
          else if expired_and_undercut > 0 then
            is_undercut_price = true
            else
            is_undercut_price = false
            end
          end
        end
      end
    end
  end

  def minimum_sales_price(item_id)
    if item_id != nil then
      crafting_cost = calculateCraftingCost(item_id)
      deposit_cost = SalesListing.cached_maximum_deposit_cost_for_item(item_id, current_user.id)
      if deposit_cost == nil then
      deposit_cost = 0
      end
      ever_sold = SalesListing.cached_sold_count_for_item(item_id, current_user.id)
      if ever_sold > 0 then
        ## last_sold_date performs better without cache when called repeatedly
        last_sold_date = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", current_user[:id]], :select => "sales_listings.id, item_id, listing_statuses.description, user_id, sales_listings.updated_at").last.updated_at
        number_of_relists_since_last_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and sales_listings.updated_at > ? and user_id = ?", item_id, "Expired", last_sold_date, current_user[:id]])
        if number_of_relists_since_last_sold > 0 then
        minimum_price = ((number_of_relists_since_last_sold * deposit_cost) + crafting_cost)
        else
        minimum_price = (deposit_cost + crafting_cost)
        end
      else
        number_of_relists = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Expired", current_user[:id]])
        if number_of_relists > 0 then
        minimum_price = ((number_of_relists * deposit_cost) + crafting_cost)
        else
        minimum_price = (deposit_cost + crafting_cost)
        end
      end
    end
  end

  def calculateCraftingCost(item_id)
    if item_id != nil then
      item = Item.cached_item(item_id)
      if item.is_crafted then
        if CraftedItem.cached_crafted_item_count(item.itemkey) > 0 then
          crafting_materials = CraftedItem.cached_crafted_item_by_component_item_id(item.itemkey)
          cost = 0
          crafting_materials.each do |materials|
            component = Item.cached_item_by_itemkey(materials.component_item_id)
            material_cost = calculateCraftingCost(component[:id])
            total_material_cost = (material_cost * materials.component_item_quantity)
            if (material_cost.to_s != "no pattern defined yet for a sub-component") then
            cost += total_material_cost
            else
            return "no pattern defined yet for a sub-component"
            end
          end
        return cost
        else
        return "no pattern defined yet for a sub-component"
        end
      else
      return calculateBuyingCost(item_id)
      end
    end
  end

  def calculateBuyingCost(item_id)
    item = Item.cached_item(item_id)
    selling_price = item.vendor_selling_price
    buying_price = item.vendor_buying_price
    override_price = PriceOverride.cached_price_override_for_item_for_user(@current_user.id, item_id)
    if (override_price != nil) then
    return override_price.price_per
    else
      if (selling_price != nil) then
      return selling_price
      else if (buying_price != nil) then
        return buying_price
        else
        return "No price defined for item"

        end
      end
    end
  end

  def calculateProfit(listing_id)
    listing = SalesListing.cached_saleslisting(listing_id)
    price_per = listing.price
    stacksize = listing.stacksize

    price = price_per * stacksize
    if price > 0 then
    ah_cut = (price * 0.05).to_i
    deposit_cost = listing.deposit_cost
    minimumCost = minimum_sales_price(SalesListing.cached_saleslisting(listing_id).item_id)
    profit = ((price + deposit_cost) - (minimumCost + ah_cut))
    return profit
    end
  end

## -- private block
end
