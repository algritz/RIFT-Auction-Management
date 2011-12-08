class ParsedAuctionsController < ApplicationController
  respond_to :html, :js
  # GET /parsed_auctions
  # GET /parsed_auctions.json
  def index
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    @parsed_auction = ParsedAuction.new

  end

  # POST /parsed_auctions
  # POST /parsed_auctions.json
  def create
    @parsed_auction = ParsedAuction.new(params[:parsed_auction])

    begin
      file = params[:parsed_auction][:item_name].open
      substring = "You received:"
      crafted_substring = "You have successfully crafted"
      @last_line_parsed = "Start of file process"
      ongoing_listing_status = ListingStatus.cached_listing_status_from_description("Ongoing")
      while (line = file.gets)
        if line.index(substring) != nil and @last_line_parsed.index(crafted_substring) == nil then
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
            sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", ongoing_listing_status[:id], item_id[:id], current_user[:id]])

            if sales_listing != nil then
              # checks if it was already added to the expired list
              previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
              if previously_added == 0 then
              # creates a new Entry to be processed later on
              parsed_auction_line = ParsedAuction.new(:user_id => current_user[:id],:sales_listing_id => sales_listing[:id], :item_name => item_name)
              parsed_auction_line.save
              SalesListing.clear_saleslisting_block(nil, current_user[:id], nil)
              SalesListing.clear_saleslisting_block(item_id, current_user[:id], nil)
              SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
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
    @parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    redirect_to parsed_auctions_url
  end

  def batch_expire
    parsed_auctions = ParsedAuction.find(:all, :conditions => ["user_id = ?", current_user[:id]])
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

  def export_data
    in_inventory = ListingStatus.first(:conditions => ["description = ?",  "In Inventory"])

    items_in_inventory = SalesListing.joins("left join items on items.id = sales_listings.item_id").find(:all, :conditions => ["user_id = ? and listing_status_id = ?",  current_user[:id], in_inventory[:id]], :order => "items.description")
    destfile = "prices.lua"
    #if File.exists?(destfile) then
    #File.delete(destfile)
    #end
    #myfile = File.new(destfile, "w")
    #myfile.puts("item_prices = {{")
    @myfilecontent = "item_prices = {{"
    items_in_inventory.each do |listing|
      item_id = listing[:item_id]
      item_info = Item.first(:conditions => ["id = ?",  item_id])
     # myfile.puts("{'#{item_info[:description]}', '#{formatPrice(listing[:price])}'},")
      @myfilecontent += "{'#{item_info[:description]}', '#{formatPrice(listing[:price])}'},"
    end
    #myfile.puts("}}")
    #myfile.close
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

  # this method is also present in application_helper, so any bug found
  # in this block is likely to happen over there
  def lastSalesPrice(item_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description('Sold')
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold = SalesListing.cached_last_sold_auction(sold_status[:id], item_id, current_user.id)
      last_sold_date = SalesListing.cached_last_sold_date(sold_status[:id], item_id, current_user.id)
      expired_listing = SalesListing.cached_expired_listing(expired_status[:id], item_id, current_user.id)

      if sold != nil then
        if (sold.updated_at == last_sold_date.updated_at) then
        price = (sold.price * 1.1).round
        else
        price = sold.price
        end
      else if expired_listing != nil then
          if last_sold_date != nil then
          @number_of_expired = SalesListing.cached_expired_count(expired_status[:id], item_id, current_user.id, last_sold_date.updated_at)
          else
          @number_of_expired = SalesListing.cached_expired_count_overall(expired_status[:id], item_id, current_user.id)

          end
          if @number_of_expired.modulo(5) == 0 then
          price = (expired_listing.price * 0.97).round
          else
          price = expired_listing.price
          end
        else
          listed_but_not_sold = SalesListing.cached_listed_but_not_sold(expired_status[:id], item_id, current_user.id)
          if listed_but_not_sold != nil then
          price = listed_but_not_sold.price
          else
          price = 0
          end
        end
      end
    end
  end

  # this method is also present in the application helper, so any bug found there is likely to happen here
  def lastIsUndercutPrice(item_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description("Sold")
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold_not_undercut = SalesListing.cached_sold_not_undercut_count(item_id, current_user.id, sold_status[:id])
      expired_not_undercut = SalesListing.cached_expired_not_undercut_count(item_id, current_user.id, expired_status[:id])
      sold_and_undercut = SalesListing.cached_sold_and_undercut_count(item_id, current_user.id, sold_status[:id])
      expired_and_undercut = SalesListing.cached_expired_and_undercut_count(item_id, current_user.id, expired_status[:id])

      if sold_not_undercut > 0 then
      is_undercut_price = false
      else if expired_not_undercut > 0 then
        is_undercut_price = false
        else if sold_and_undercut > 0 then
          is_undercut_price = true
          else if expired_and_undercut > 0 then
            is_undercut_price = true
            else
            is_undercut_price = false
            end
          end
        end
      end
    end
  end

  def formatPrice(price)
    if price.class != String then
      if price.to_i > 0 then
        if price != nil then
        plat = price / 10000
        goldRemaining = price % 10000
        gold = goldRemaining / 100
        silver = goldRemaining % 100
        return "#{plat}p #{gold}g #{silver}s"
        else
        return ""
        end
      end
    else
    return price
    end
  end

end
