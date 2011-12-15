class ParsedAuctionsController < ApplicationController
  respond_to :html, :js
  # GET /parsed_auctions
  # GET /parsed_auctions.json
  def index
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]], :order => "item_name")
    @parsed_auction = ParsedAuction.new

  end

  # POST /parsed_auctions
  # POST /parsed_auctions.json
  def create
    @parsed_auction = ParsedAuction.new(params[:parsed_auction])

    begin
      file = params[:parsed_auction][:item_name].open
      received_substring = "You received:"
      auction_substring = "Auction Created for:"
      crafted_substring = "You have successfully crafted"
      @last_line_parsed = "Start of file process"
      ongoing_listing_status = ListingStatus.cached_listing_status_from_description("Ongoing")
      in_inventory_listing_status = ListingStatus.cached_listing_status_from_description("In Inventory")
      mailed_listing_status = ListingStatus.cached_listing_status_from_description("Mailed")
      crafted_listing_status = ListingStatus.cached_listing_status_from_description("Crafted")
      while (line = file.gets)
        if line.index(received_substring) != nil and @last_line_parsed.index(crafted_substring) == nil then
          # This is either an expired auction or something crafted
          # deconstruct the line in order to get the actual item_name
          item_name_a = line.split(":")
          item_name = item_name_a[4]
          if item_name.index("[") != nil then
            end_str_pos = item_name.index("]")
            item_name = item_name[2..end_str_pos-1]
            # fetch item_id from item_name
            item_id = Item.cached_item_name(item_name)
            # fetch if there is an active listings
            sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", ongoing_listing_status[:id], item_id[:id], current_user[:id]], :select => "id, listing_status_id, item_id, user_id")
            # this is an ongoing auction
            if sales_listing != nil then
              # checks if it was already added to the expired list
              previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
              if previously_added == 0 then
              # creates a new Entry to be processed later on
              parsed_auction_line = ParsedAuction.new(:user_id => current_user[:id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "Expired")
              parsed_auction_line.save
              SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
              SalesListing.clear_saleslisting_block(item_id, current_user[:id], nil)
              SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
              end
            else
            # this is a mailed auction
              sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", mailed_listing_status[:id], item_id[:id], current_user[:id]], :select => "id, listing_status_id, item_id, user_id")
              if sales_listing != nil then
                # checks if it was already added to the mailed list
                previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
                if previously_added == 0 then
                # creates a new Entry to be processed later on
                parsed_auction_line = ParsedAuction.new(:user_id => current_user[:id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "In Inventory")
                parsed_auction_line.save
                SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
                SalesListing.clear_saleslisting_block(item_id, current_user[:id], nil)
                SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
                end
              else
              #this is a crafted auction
                sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", crafted_listing_status[:id], item_id[:id], current_user[:id]], :select => "id, listing_status_id, item_id, user_id")
                if sales_listing != nil then
                  # checks if it was already added to the mailed list
                  previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
                  if previously_added == 0 then
                  # creates a new Entry to be processed later on
                  parsed_auction_line = ParsedAuction.new(:user_id => current_user[:id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "In Inventory")
                  parsed_auction_line.save
                  SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
                  SalesListing.clear_saleslisting_block(item_id, current_user[:id], nil)
                  SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
                  end
                end
              end
            end
          end
        else
          if line.index(auction_substring) != nil then
            item_name_a = line.split(":")
            item_name = item_name_a[4]
            if item_name.index("[") != nil then
              end_str_pos = item_name.index("]")
              item_name = item_name[2..end_str_pos-1]
              # fetch item_id from item_name
              item_id = Item.cached_item_name(item_name)
              # fetch if there is an active listings
              sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", in_inventory_listing_status[:id], item_id[:id], current_user[:id]], :select => "id, listing_status_id, item_id, user_id")
              if sales_listing != nil then
                # checks if it was already added to the expired list
                previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
                if previously_added == 0 then
                # creates a new Entry to be processed later on
                parsed_auction_line = ParsedAuction.new(:user_id => current_user[:id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "Relist")
                parsed_auction_line.save
                SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
                SalesListing.clear_saleslisting_block(item_id, current_user[:id], nil)
                SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
                end
              end
            end
          end
        end
        @last_line_parsed = line
      end

      file.close

    rescue => err
    puts "Exception: #{err}"
    err
    end
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]], :order => "item_name")
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
