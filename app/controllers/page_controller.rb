class PageController < ApplicationController
  before_filter :authenticate
  def items_to_craft
    @source_list = Source.cached_sources_crafting_allowed
    toons = Toon.all_cached_toon_for_user(current_user[:id])
    toon_skills = ToonSkillLevel.find(:all, :conditions => ["toon_id in (?)", toons])
    @known_patterns = []
    toon_skills.each do |skill|
      source = Source.cached_source(skill.source_id)
      item_keys = CraftedItem.find(:all, :conditions => ["required_skill = ? and required_skill_point <= ?", source.description, skill.skill_level], :select => "id, required_skill, required_skill_point, crafted_item_generated_id")
      item_keys.each do |key|
        item_id = Item.cached_item_by_itemkey(key[:crafted_item_generated_id])
        @known_patterns << item_id[:id]
      end
    end
    source = Source.find(:all, :conditions => ["description = ?", params[:param]])
    ongoing_item_ids = SalesListing.ongoing_listing_count_cached_for_user(current_user[:id])
    ongoing_item_ids_list = [0]
    ongoing_item_ids.each do |id|
      ongoing_item_ids_list << id.item_id
    end
    if source != nil && params[:param] != nil then
      if params[:search] == nil then
        item_ids = Item.find(:all, :conditions => ["to_list = ? and source_id = ? and is_crafted = ? and id not in (?)", true, source.first.id, true, ongoing_item_ids_list], :select => "id, description, source_id", :order => "source_id, description")
      else
        item_ids = Item.where(["to_list = ? and source_id = ? and is_crafted = ? and id not in (?)", true, source.first.id, true, ongoing_item_ids_list]).search(params[:search], params[:page])
      end
    else
      if params[:search] == nil then
        #item_ids = Item.find(:all, :conditions => ["to_list = ? and is_crafted = ? and id not in (?)", true, true, ongoing_item_ids_list], :select => "id, description, source_id", :order => "source_id, description")
        item_ids= Item.cached_items_without_listings(current_user[:id], ongoing_item_ids_list)
      else
        item_ids = Item.where(["to_list = ? and is_crafted = ? and id not in (?)", true, true, ongoing_item_ids_list]).search(params[:search], params[:page])
      end
    end
    sold = ListingStatus.cached_listing_status_from_description("Sold")
    expired = ListingStatus.cached_listing_status_from_description("Expired")
    @out_of_stock_list = []
    i = 0
    item_ids.each do |ids|
      active_autions = SalesListing.active_auctions_cached_for_user(ids.id, sold.id, expired.id, current_user[:id])
      if active_autions == 0 then

        if @known_patterns.index(ids[:id]) != nil then
          @out_of_stock_list << ids[:id]
        i+=1
        end
      end
      if i==10 then
      @had_to_limit = true
      break
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @out_of_stock_list }
    end
  end

  def getSourceDescriptionForItemsToCraft (id)
    Source.cached_source(Item.cached_item(id).source_id).description
  end

  def items_to_list_from_bank
    ongoing = ListingStatus.find(:all, :conditions => ["description = ?", 'Ongoing']).first
    in_bank = ListingStatus.find(:all, :conditions => ["description = ?", 'In Bank']).first
    in_inventory = ListingStatus.find(:all, :conditions => ["description = ?", 'In Inventory']).first
    @sitting_in_bank = []
    @last_id_in_bank
    items_in_bank = SalesListing.find(:all, :conditions => ["listing_status_id = ? and user_id = ?", in_bank[:id], current_user[:id]])
    items_in_bank.each do |ids|
      active_autions = SalesListing.count(ids[:item_id], :conditions => ["item_id = ? and listing_status_id in (?, ?) and user_id = ?", ids[:item_id], ongoing[:id], in_inventory[:id], current_user[:id]])
      if active_autions == 0 then
        if ids[:item_id] != @last_id_in_bank then
          @sitting_in_bank << ids[:item_id]
          @last_id_in_bank = ids[:item_id]
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
    ongoing_item_ids = SalesListing.find_by_sql(["select distinct item_id from sales_listings where user_id = ? and listing_status_id not in (5,1)", current_user[:id]])
    ongoing_item_ids_list = []
    ongoing_item_ids.each do |id|
      ongoing_item_ids_list << id.item_id
    end
    ongoing_item_ids_list.each do |ids|
      active_autions = SalesListing.count(:id, :conditions => ["item_id = ? and listing_status_id = ? and user_id = ?", ids, ongoing[:id], current_user[:id]])
      if active_autions >= 2 then
        if ids !=  @last_duplicate then
        @duplicate_listing << ids
        @last_duplicate = ids
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
    @old_listings = SalesListing.find(:all, :conditions => ["updated_at < ? and listing_status_id = ? and user_id = ?", 5.days.ago, listing_status_id, current_user[:id]], :select => "id, item_id, stacksize, price, deposit_cost")
  end
  
  

  def all_mailed
    crafted_id = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Crafted'")
    mailed_listing = ListingStatus.find(:all, :select => 'id, description', :conditions => "description = 'Mailed'")

    @salesListing = SalesListing.find(:all, :conditions => ["listing_status_id = ? and user_id = ?", crafted_id, current_user[:id]])
    @salesListing.each do |listing|
      listing.listing_status_id = mailed_listing.first[:id]
      listing.save
    end
    SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)

    redirect_to sales_listings_path

  end

  def profit_per_day

    @salesListing = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").sum(:price,
    :conditions => (["sales_listings.user_id = ? and listing_statuses.description = ?", current_user[:id], "Sold"]),
    :group => ("DATE(sales_listings.updated_at)"), :order => "DATE(sales_listings.updated_at) desc")

  end

end
