class PageController < ApplicationController
  def items_to_craft
    item_ids = Item.find(:all, :conditions => "to_list = 't'", :select => "id")
    sold = ListingStatus.find(:all, :conditions => "description ='Sold'").first
    @out_of_stock_list = []
    item_ids.each do |ids|
      active_autions = SalesListing.count(ids.id, :conditions => "item_id = #{ids.id} and listing_status_id <> '#{sold.id}'")
      if active_autions == 0 then
      @out_of_stock_list << ids.id
      end
    end
  end

  def getSourceDescriptionForItemsToCraft (id)
    Source.find(Item.find(id).source_id).description
  end

  def items_to_list_from_bank
    item_ids = Item.find(:all, :conditions => "to_list = 't'", :select => "id")
    ongoing = ListingStatus.find(:all, :conditions => "description ='Ongoing'").first
    in_bank = ListingStatus.find(:all, :conditions => "description ='In Bank'").first
    @sitting_in_bank = []
    item_ids.each do |ids|
      items_in_bank = SalesListing.find(:all, :conditions => "item_id = #{ids.id} and listing_status_id = #{in_bank.id}")
      #readjust queries to have actual results
      items_in_bank.each do |ids_in_bank|
        active_autions = SalesListing.count(ids_in_bank.item_id, :conditions => "item_id = #{ids_in_bank.item_id} and listing_status_id = #{ongoing.id}")
        if active_autions == 0 then
        @sitting_in_bank << ids.id
        end
      end
    end
  end

end
