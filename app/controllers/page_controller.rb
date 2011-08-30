class PageController < ApplicationController
  ActionController::Base.logger = Logger.new(STDOUT)
  before_filter :authenticate
  def items_to_craft
    item_ids = Item.find(:all, :conditions => ["to_list = ?", true], :select => "id, description, source_id", :order => "source_id, description")
    sold = ListingStatus.find(:all, :conditions => ["description = ?", 'Sold']).first
    expired = ListingStatus.find(:all, :conditions => ["description = ?", 'Expired']).first
    @out_of_stock_list = []
    item_ids.each do |ids|
      active_autions = SalesListing.count(ids.id, :conditions => ["item_id = ? and listing_status_id not in (?, ?) and user_id = ?", ids.id, sold.id, expired.id, current_user.id])
      if active_autions == 0 then
      @out_of_stock_list << ids.id
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @out_of_stock_list }
    end
  end

  def getSourceDescriptionForItemsToCraft (id)
    Source.find(Item.find(id).source_id).description
  end

  def items_to_list_from_bank
    item_ids = Item.find(:all, :conditions => ["to_list = ?", true], :select => "id, description, source_id", :order => "source_id, description")
    ongoing = ListingStatus.find(:all, :conditions => ["description = ?", 'Ongoing']).first
    in_bank = ListingStatus.find(:all, :conditions => ["description = ?", 'In Bank']).first
    @sitting_in_bank = []
    @last_id_in_bank
    item_ids.each do |ids|
      items_in_bank = SalesListing.find(:all, :conditions => ["item_id = ? and listing_status_id = ? and user_id = ?", ids.id, in_bank.id, current_user.id])
      items_in_bank.each do |ids_in_bank|
        active_autions = SalesListing.count(ids_in_bank.item_id, :conditions => ["item_id = ? and listing_status_id = ? and user_id = ?", ids_in_bank.item_id, ongoing.id, current_user.id])
        if active_autions == 0 then
          if ids.id !=  @last_id_in_bank then
          @sitting_in_bank << ids.id
          @last_id_in_bank = ids.id
          end
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sitting_in_bank }
    end
  end

  def items_with_more_than_one_listings
    item_ids = Item.find(:all, :conditions => ["to_list = ?", true], :select => "id, description, source_id", :order => "source_id, description")
    ongoing = ListingStatus.find(:all, :conditions => ["description = ?", 'Ongoing']).first
    @duplicate_listing = []
    @last_duplicate
    item_ids.each do |ids|
      p ids
      active_autions = SalesListing.count(ids.id, :conditions => ["item_id = ? and listing_status_id = ? and user_id = ?", ids.id, ongoing.id, current_user.id])
      if active_autions >= 2 then
        if ids.id !=  @last_duplicate then
        @duplicate_listing << ids.id
        @last_duplicate = ids.id
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @duplicate_listing }
    end
  end

  def old_listings
    listing_status_id = ListingStatus.find(:all, :select => "id, description" ,:conditions => ["description = ?", "Ongoing"])
    @old_listings = SalesListing.find(:all, :conditions => ["updated_at < ? and listing_status_id = ? and user_id = ?", 5.days.ago, listing_status_id, current_user.id])
  end

  def all_mailed
    crafted_id = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Crafted'")
    mailed_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Mailed'")

    @salesListing = SalesListing.find(:all, :conditions => ["listing_status_id = ? and user_id = ?", crafted_id, current_user.id])
    @salesListing.each do |listing|
      listing.listing_status_id = mailed_listing.first.id
      listing.save
    end
    redirect_to sales_listings_path
  end

  def profit_per_day

    @sold_list_dates = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").find(:all,
     :conditions => ["user_id = ? and listing_statuses.description = ?", current_user.id, "Sold"],
     :order => "sales_listings.updated_at desc", 
     :select => "distinct sales_listings.id, listing_statuses.description, strftime('%y-%m-%d', sales_listings.updated_at)",
     :group => "strftime('%y-%m-%d', sales_listings.updated_at)")
   

    @total_profit =[]
    @date_list = []
    @profit_for_the_day
    @previous_date = nil
    @profit_for_the_day = 0
    @sold_list_dates.each do |listing|
      date_listing = listing.updated_at

      if date_listing != @previous_date then

        @sold_list_for_day = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["user_id = ? and listing_statuses.description = ? and sales_listings.updated_at = ?", current_user, "Sold", date_listing])
        logger.info("@sold_list_for_day = #{@sold_list_for_day}")
        @profit_for_listing = 0
        @sold_list_for_day.each do |sold_that_day|
          @profit_for_listing += calculateProfit(sold_that_day.id)
        end
        @total_profit << @profit_for_listing.to_s + "<br />"

        @previous_date = listing.updated_at
        @date_list << listing.updated_at
      end
    end
  end

  ## Application helper methos that needs to be proted over ##
  def calculateCraftingCost(id)
    if id != nil then
      if Item.find(id).is_crafted then
        if CraftedItem.where(["crafted_item_generated_id = ?", id]).exists? then
          crafting_materials = CraftedItem.find(:all, :conditions => ["crafted_item_generated_id = ?", id])
          cost = 0
          crafting_materials.each do |materials|
            material_cost = calculateCraftingCost(materials.component_item_id)
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
    selling_price = Item.find(id).vendor_selling_price
    buying_price = Item.find(id).vendor_buying_price

    if (selling_price != nil) then
    return selling_price
    else if (buying_price != nil) then
      return buying_price
      else
        return "No price defined for item"
      end
    end
  end

  def calculateProfit(id)
    price = SalesListing.find(id).price
    if price > 0 then
      ah_cut = (price * 0.05).to_i

      deposit_cost = SalesListing.find(id).deposit_cost
      buyingCost = calculateBuyingCost(SalesListing.find(id).item_id)
      if Item.find(SalesListing.find(id).item_id).is_crafted then
        if CraftedItem.where(["crafted_item_generated_id = ?", SalesListing.find(id).item_id]).exists? then
          crafting_materials = CraftedItem.find(:all, :conditions => ["crafted_item_generated_id = ?", SalesListing.find(id).item_id])
          cost = 0
          crafting_materials.each do |materials|
            material_cost = calculateCraftingCost(materials.component_item_id)
            total_material_cost = (material_cost * materials.component_item_quantity)
            if (material_cost.to_s != "no pattern defined yet for a sub-component") then
            cost += total_material_cost
            else
              return "no pattern defined yet for a sub-component"
            end
          end
        profit = ((price + deposit_cost )- (cost + ah_cut))
        return profit
        else
          return "no pattern defined yet"
        end
      else
      profit = ((price + deposit_cost) - (buyingCost + ah_cut))
      return profit
      end
    end
  end

end
