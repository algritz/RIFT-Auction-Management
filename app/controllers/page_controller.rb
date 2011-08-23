class PageController < ApplicationController
  def items_to_craft
    item_ids = Item.find(:all, :conditions => ["to_list = ?", true], :select => "id, description, source_id", :order => "source_id, description")
    sold = ListingStatus.find(:all, :conditions => ["description = ?", 'Sold']).first
    expired = ListingStatus.find(:all, :conditions => ["description = ?", 'Expired']).first
    @out_of_stock_list = []
    item_ids.each do |ids|
      active_autions = SalesListing.count(ids.id, :conditions => ["item_id = ? and listing_status_id not in (?, ?)", ids.id, sold.id, expired.id ])
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
      items_in_bank = SalesListing.find(:all, :conditions => ["item_id = ? and listing_status_id = ?", ids.id, in_bank.id])
      items_in_bank.each do |ids_in_bank|
        active_autions = SalesListing.count(ids_in_bank.item_id, :conditions => ["item_id = ? and listing_status_id = ?", ids_in_bank.item_id, ongoing.id])
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
      active_autions = SalesListing.count(ids.id, :conditions => ["item_id = ? and listing_status_id = ?", ids.id, ongoing.id])
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
    @old_listings = SalesListing.find(:all, :conditions => ["updated_at < ? and listing_status_id = ?", 5.days.ago, listing_status_id])
  end

end
