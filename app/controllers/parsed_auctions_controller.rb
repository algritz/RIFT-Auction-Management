class ParsedAuctionsController < ApplicationController
  respond_to :html, :js
  # GET /parsed_auctions
  # GET /parsed_auctions.json
  def index
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]], :order => "item_name")
    @parsed_auction = ParsedAuction.new
    @jobs_in_queue = ParseQueue.count(:id)
  end

  # POST /parsed_auctions
  # POST /parsed_auctions.json
  def create
    begin
      file = params[:parsed_auction][:item_name].open
      file_content = "Start of File\n"
      while (line = file.gets)
        file_content += line
      end
      entry = ParseQueue.new(:user_id => current_user[:id], :content => file_content)
      entry.save
      entry.delay.create_delayed
    rescue => err
    puts "Exception: #{err}"
    err
    end
    redirect_to parsed_auctions_url
  end

  def batch_expire
    parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ? and action_name = ?", current_user[:id], "Expired"])
    expired_listing_status = ListingStatus.cached_listing_status_from_description("Expired")
    inventory_listing_status = ListingStatus.cached_listing_status_from_description("In Inventory")

    parsed_auctions.each do |auction|
      sales_listing = SalesListing.find(:first, :conditions => ["id = ?", auction[:sales_listing_id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
      if sales_listing.relisted_status != true then
      sales_relisting = SalesListing.new(:item_id => sales_listing.item_id,
      :stacksize => sales_listing.stacksize,
      :deposit_cost => sales_listing.deposit_cost,
      :listing_status_id => inventory_listing_status[:id],
      :price => lastSalesPrice(sales_listing.item_id),
      :is_undercut_price => lastIsUndercutPrice(sales_listing),
      :user_id => current_user[:id])

      sales_listing.listing_status_id = expired_listing_status[:id]
      sales_listing.relisted_status = true
      sales_listing.save
      sales_relisting.save
      parsed_auction = ParsedAuction.find(auction[:id])
      parsed_auction.destroy
      SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(sales_listing.item_id, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
      end
    end
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    redirect_to parsed_auctions_url
  end

  def batch_relist
    parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ? and action_name = ?", current_user[:id], "Relist"])
    ongoing_listing_status = ListingStatus.cached_listing_status_from_description("Ongoing")
    inventory_listing_status = ListingStatus.cached_listing_status_from_description("In Inventory")

    parsed_auctions.each do |auction|
      sales_listing = SalesListing.find(:first, :conditions => ["id = ?", auction[:sales_listing_id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
      sales_listing.listing_status_id = ongoing_listing_status[:id]
      sales_listing.save
      parsed_auction = ParsedAuction.find(auction[:id])
      parsed_auction.destroy
      SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(sales_listing.item_id, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
    end
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    redirect_to parsed_auctions_url
  end

  def batch_in_inventory
    parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ? and action_name = ?", current_user[:id], "In Inventory"])
    inventory_listing_status = ListingStatus.cached_listing_status_from_description("In Inventory")

    parsed_auctions.each do |auction|
      sales_listing = SalesListing.find(:first, :conditions => ["id = ?", auction[:sales_listing_id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
      sales_listing.listing_status_id = inventory_listing_status[:id]
      sales_listing.save
      parsed_auction = ParsedAuction.find(auction[:id])
      parsed_auction.destroy
      SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(sales_listing.item_id, current_user[:id], nil)
      SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
    end
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    redirect_to parsed_auctions_url
  end

  def export_data
    in_inventory = ListingStatus.first(:conditions => ["description = ?",  "In Inventory"])

    items_in_inventory = SalesListing.joins("left join items on items.id = sales_listings.item_id").find(:all, :conditions => ["user_id = ? and listing_status_id = ?",  current_user[:id], in_inventory[:id]], :order => "items.description")
    @myfilecontent = "item_prices = {{"
    items_in_inventory.each do |listing|
      item_id = listing[:item_id]
      item_info = Item.first(:conditions => ["id = ?",  item_id])
      @myfilecontent += '{"' + item_info[:description] + '", '+ "'#{formatPrice(listing[:price])} / #{formatPrice(minimum_sales_price(listing[:item_id]))}'},"
    end
    @myfilecontent = @myfilecontent[0..@myfilecontent.length-2]
    @myfilecontent += "}}"
    respond_to do |format|
      format.html
    end

  end

  # DELETE /parsed_auctions/1l
  # DELETE /parsed_auctions/1.json
  def destroy
    @parsed_auction = ParsedAuction.find(params[:id])
    @parsed_auction.destroy
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    redirect_to parsed_auctions_url
  end

end
