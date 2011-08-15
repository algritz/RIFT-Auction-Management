module ItemsHelper
  def get_single_auction_id(item_id)
    sales_listing = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").count(item_id, :conditions => "description = 'Ongoing' and item_id = '#{item_id}'")
    if sales_listing == 1 then
      @auction_id = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => "description = 'Ongoing' and item_id = '#{item_id}'")
    end
  end

end
