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
        #@sales_listings = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").joins("left join items on items.id = sales_listings.item_id").paginate(:page => params[:page],
        #:order => "position, items.description, sales_listings.updated_at desc", :conditions => ["listing_statuses.is_final = ? and user_id = ?", false, current_user[:id]])
        @sales_listings = SalesListing.all_cached(current_user[:id]).paginate(:page => params[:page])
      end
    end
    @status_list = ListingStatus.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sales_listings }
    end
  end

  # GET /sales_listings/1
  # GET /sales_listings/1.xml
  def show
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, item_id, stacksize, price, is_undercut_price, deposit_cost, is_tainted, listing_status_id")
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :order => 'description')
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

    @items = Item.find(:all, :select => 'id, description', :order => 'description', :conditions => ["to_list = ? and isaugmented = ? and soulboundtrigger <> ? and rarity <>  ?", true, false, "BindOnPickup", "Trash"])
    @item_details = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :order => 'description', :conditions => ["id = ?", @sales_listing.item_id])

    @listing_statuses = ListingStatus.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sales_listing }
      format.js
    end
  end

  # GET /sales_listings/1/edit
  def edit
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, item_id, stacksize, price, is_undercut_price, deposit_cost, is_tainted, listing_status_id")
    @item_details = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :order => 'description', :conditions => ["id = ?", @sales_listing.item_id])
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
    @listing_statuses = ListingStatus.find(:all, :select => "id, description", :order => "description")
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description')
    respond_to do |format|
      if @sales_listing.save
        format.html { redirect_to(sales_listings_path, :notice => 'Sales listing was successfully created.') }
        format.xml  { render :xml => @sales_listing, :status => :created, :location => @sales_listing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sales_listing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sales_listings/1
  # PUT /sales_listings/1.xml
  def update
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
    @listing_statuses = ListingStatus.find(:all, :select => "id, description", :order => "description")
    @expired_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'Expired'])
    @inventory_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'In Inventory'])
    @sold_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'Sold'])
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description').first
    respond_to do |format|
      if @sales_listing.update_attributes(params[:sales_listing])

        params[:sales_listing].each do |key, value|
          if key == "listing_status_id" then
            if value.to_i ==  @expired_listing.first.id then
              if @sales_listing.relisted_status != true then
                @sales_relisting = SalesListing.new(:item_id => @sales_listing.item_id,
                :stacksize => @sales_listing.stacksize,
                :deposit_cost => @sales_listing.deposit_cost,
                :listing_status_id => @inventory_listing.first.id,
                :price => lastSalesPrice(@sales_listing.item_id),
                :is_undercut_price => @sales_listing.is_undercut_price,
                :user_id => current_user[:id])
              @sales_relisting.listing_status_id = @inventory_listing.first.id
              @sales_listing.relisted_status = true
              @sales_listing.save
              @sales_relisting.save
              end
            else if value.to_i ==  @sold_listing.first.id then
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
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id")
    if (is_current_user?(@sales_listing.user_id)) then
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
    @sales_listing = SalesListing.create!(:item_id => params[:id], :is_undercut => lastIsUndercutPrice(params[:id]),  :deposit_cost => lastDepositCost(params[:id]), :stacksize => 1, :user_id => current_user[:id], :listing_status_id => @crafted_listing.first.id, :price => lastSalesPrice(params[:id]))

    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description').first

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
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, listing_status_id")
    if @sales_listing.user_id == @current_user[:id] then

      @sales_listing.listing_status_id = @mailed_listing.first.id
      @sales_listing.save
      @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description').first

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
    @inventory_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'In Inventory'])
    @in_bank = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'In Bank'])
    @sales_listing = SalesListing.find(:all, :select => "id, stacksize, listing_status_id, is_undercut_price, deposit_cost, price", :conditions => ["item_id = ? and user_id = ? and listing_status_id = ?", params[:id], @current_user[:id], @in_bank]).first

    if @sales_listing.stacksize == 1 then
      @sales_listing.listing_status_id = @inventory_listing.first.id
      @sales_listing.is_undercut_price = lastIsUndercutPrice(params[:id])
      @sales_listing.deposit_cost = lastDepositCost(params[:id])
      @sales_listing.price = lastSalesPrice(params[:id])
    else
      @sales_relisting = SalesListing.create!(:item_id => params[:id], :is_undercut => lastIsUndercutPrice(params[:id]),  :deposit_cost => lastDepositCost(params[:id]), :stacksize => 1, :user_id => current_user[:id], :listing_status_id => @inventory_listing.first.id, :price => lastSalesPrice(params[:id]))
    @sales_listing.stacksize = @sales_listing.stacksize - 1
    @sales_relisting.save
    end
    @sales_listing.save
    @items = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id', :conditions=> ["to_list = ?", true], :order => 'source_id, description').first

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
    @sales_listing = SalesListing.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")

    if @sales_listing.user_id == @current_user[:id] then
      @ongoing_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => ["description = ?", 'Ongoing'])

      @sales_listing.listing_status_id = @ongoing_listing.first.id
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
  def lastSalesPrice(id)
    if id != nil then
      sold_status = ListingStatus.find(:first, :conditions => ["description = ?", 'Sold'], :select => "id, description")
      expired = ListingStatus.find(:first, :conditions => ["description = ?", 'Expired'], :select => "id, description")
      sold = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status.id, id, false, current_user.id], :select => "id, listing_status_id, item_id, is_undercut_price, user_id, price, updated_at")
      last_sold_date = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", sold_status.id, id, current_user.id], :select => "id, listing_status_id, item_id, user_id, updated_at")
      expired_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user.id], :select => "id, listing_status_id, item_id, is_undercut_price, user_id, price, updated_at")
      if sold != nil then
        if (sold.updated_at == last_sold_date.updated_at) then
        price = (sold.price * 1.1).round
        else
        price = sold.price
        end
      else if expired_listing != nil then
          if last_sold_date != nil then
            @number_of_expired = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and updated_at < ? and user_id = ?", expired.id, id, false, last_sold_date.updated_at, current_user.id] )
          else
            @number_of_expired = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user.id] )
          end
          if @number_of_expired.modulo(5) == 0 then
          price = (expired_listing.price * 0.97).round
          else
          price = expired_listing.price
          end
        else
          listed_but_not_sold = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user.id], :select => "id, price, listing_status_id, item_id, is_undercut_price, user_id")
          if listed_but_not_sold != nil then
          price = listed_but_not_sold.price
          else
          price = 0
          end
        end
      end
    end
  end

  def lastDepositCost(id)
    if id != nil then
      SalesListing.maximum('deposit_cost', :conditions => ["item_id = ? and user_id = ?", id, current_user[:id]]).to_i
    end
  end

  # this method is also present in the application helper, so any bug found there is likely to happen here
  def lastIsUndercutPrice(id)
    if id != nil then
      sold_status = ListingStatus.find(:all, :conditions => ["description = ?", 'Sold'], :select => "id, description").first
      expired = ListingStatus.find(:all, :conditions => ["description = ?", 'Expired'], :select => "id, description").first
      sold_not_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status.id, id, false, current_user[:id]])
      expired_not_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user[:id]])
      sold_and_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status.id, id, true, current_user[:id]])
      expired_and_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, true, current_user[:id]])

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
      deposit_cost = SalesListing.maximum("deposit_cost", :conditions => ["item_id = ? and user_id = ?", item_id, current_user[:id]])
      if deposit_cost == nil then
      deposit_cost = 0
      end
      ever_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", current_user[:id]])
      if ever_sold > 0 then
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

  def calculateCraftingCost(id)
    if id != nil then
      item = Item.find(id)

      if item.is_crafted then
        if CraftedItem.count(:all, :conditions=> ["crafted_item_generated_id = ?", item.itemkey], :select => "id, crafted_item_generated_id") > 0 then
          crafting_materials = CraftedItem.find(:all, :conditions => ["crafted_item_generated_id = ?", item.itemkey], :select => "id, crafted_item_generated_id, component_item_id, component_item_quantity")
          cost = 0
          crafting_materials.each do |materials|
            component = Item.find(:first, :conditions => ["itemkey = ?", materials.component_item_id])
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
        return calculateBuyingCost(id)
      end
    end
  end

  def calculateBuyingCost(id)
    item = Item.find(id)
    selling_price = item.vendor_selling_price
    buying_price = item.vendor_buying_price
    override_price = PriceOverride.find(:first, :conditions => ["user_id = ? and item_id = ?", @current_user.id, item[:id]], :select => "id, user_id, item_id, price_per")
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

  def calculateProfit(id)
    listing = SalesListing.find(:first, :conditions => ["id = ?", id], :select => "id, price, stacksize, item_id, deposit_cost")
    price_per = listing.price
    stacksize = listing.stacksize

    price = price_per * stacksize
    if price > 0 then
      ah_cut = (price * 0.05).to_i
      deposit_cost = listing.deposit_cost
      minimumCost = minimum_sales_price(listing.item_id)
    profit = ((price + deposit_cost) - (minimumCost + ah_cut))
    return profit
    end
  end

## -- private block
end
