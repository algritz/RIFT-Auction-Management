class PageController < ApplicationController
  before_filter :authenticate
  def items_to_craft
    @source_list = Source.find(:all, :conditions => ["crafting_allowed = ?", true])
    source = Source.find(:all, :conditions => ["description = ?", params[:param]])
    if source != nil && params[:param] != nil then
      if params[:search] == nil then
        item_ids = Item.find(:all, :conditions => ["to_list = ? and source_id = ?", true, source.first.id], :select => "id, description, source_id", :order => "source_id, description")
      else
        item_ids = Item.where(["to_list = ? and source_id = ?", true, source.first.id]).search(params[:search], params[:page])
      end
    else
      if params[:search] == nil then
        item_ids = Item.find(:all, :conditions => ["to_list = ?", true], :select => "id, description, source_id", :order => "source_id, description")
      else
        item_ids = Item.where(["to_list = ?", true]).search(params[:search], params[:page])
      end
    end
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
    in_inventory = ListingStatus.find(:all, :conditions => ["description = ?", 'In Inventory']).first
    @sitting_in_bank = []
    @last_id_in_bank
    item_ids.each do |ids|
      items_in_bank = SalesListing.find(:all, :conditions => ["item_id = ? and listing_status_id = ? and user_id = ?", ids.id, in_bank.id, current_user.id])
      items_in_bank.each do |ids_in_bank|
        active_autions = SalesListing.count(ids_in_bank.item_id, :conditions => ["item_id = ? and listing_status_id = ? and user_id = ?", ids_in_bank.item_id, ongoing.id, current_user.id])
        in_inventory_auctions = SalesListing.count(ids_in_bank.item_id, :conditions => ["item_id = ? and listing_status_id = ? and user_id = ?", ids_in_bank.item_id, in_inventory.id, current_user.id])
        if active_autions == 0 && in_inventory_auctions == 0 then
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

    @salesListing = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").sum(:price,
    :conditions => (["sales_listings.user_id = ? and listing_statuses.description = ?", current_user.id, "Sold"]),
    :group => ("DATE(sales_listings.updated_at)"), :order => "DATE(sales_listings.updated_at) desc")

  end


end
