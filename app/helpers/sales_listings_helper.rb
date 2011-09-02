module SalesListingsHelper
  def getDefaultItemSelected
    if params[:item_id] != nil then
      item_id = params[:item_id]
    else
    @sales_listing.item_id
    end
  end

  def getDefaultStacksize
    if params[:item_id] != nil then
    1
    else
    @sales_listing.stacksize
    end
  end

  def getDefaultPricing
    if params[:item_id] != nil then
      item_id = params[:item_id]
      lastSalesPrice(item_id)
    else
    @sales_listing.price
    end
  end

  def getDefaultStatus
    if params[:item_id] != nil then
      listing_status = ListingStatus.find(:all, :conditions => ["description = ?", 'In Inventory']).first
    listing_status.id
    else
    @sales_listing.listing_status_id
    end
  end

  def getDepositCost
    if params[:item_id] != nil then
      last_listing = SalesListing.find(:all, :conditions => ["item_id = ? and user_id = ?", params[:item_id], current_user.id]).last
      if last_listing != nil then
      last_listing.deposit_cost
      end
    else
    @sales_listing.deposit_cost
    end
  end

end
