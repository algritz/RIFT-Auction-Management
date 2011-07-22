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

end
