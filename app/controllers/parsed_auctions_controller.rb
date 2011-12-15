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

  def lastDepositCost(item_id)
    if item_id != nil then
      SalesListing.last(:select => 'deposit_cost', :conditions => ["item_id = ? and user_id = ?", item_id, current_user[:id]]).to_i
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

  def minimum_sales_price(item_id)
    if item_id != nil then
      crafting_cost = calculateCraftingCost(item_id)
      deposit_cost = SalesListing.cached_last_deposit_cost_for_item(item_id, current_user.id)
      if deposit_cost == nil then
      deposit_cost = 0
      end
      ever_sold = SalesListing.cached_sold_count_for_item(item_id, current_user.id)
      if ever_sold > 0 then
        ## last_sold_date performs better without cache when called repeatedly
        last_sold_date = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", current_user[:id]], :select => "sales_listings.id, item_id, listing_statuses.description, user_id, sales_listings.updated_at").last.updated_at
        number_of_relists_since_last_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and sales_listings.updated_at > ? and user_id = ?", item_id, "Expired", last_sold_date, current_user[:id]])
        if number_of_relists_since_last_sold > 0 then
        minimum_price = ((number_of_relists_since_last_sold * deposit_cost) + crafting_cost)
        else
        minimum_price = (deposit_cost + crafting_cost)
        end
      else
        number_of_relists = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Expired", current_user[:id]])
        if number_of_relists > 0 then
        minimum_price = ((number_of_relists * deposit_cost) + crafting_cost)
        else
        minimum_price = (deposit_cost + crafting_cost)
        end
      end
    end
  end

  def calculateCraftingCost(item_id)
    if item_id != nil then
      item = Item.cached_item(item_id)
      if item.is_crafted then
        if CraftedItem.cached_crafted_item_count(item.itemkey) > 0 then
          crafting_materials = CraftedItem.cached_crafted_item_by_component_item_id(item.itemkey)
          cost = 0
          crafting_materials.each do |materials|
            component = Item.cached_item_by_itemkey(materials.component_item_id)
            material_cost = calculateCraftingCost(component[:id])
            total_material_cost = (material_cost * materials.component_item_quantity)
            if (material_cost.to_s != "no pattern defined yet for a sub-component") then
            cost += total_material_cost
            else
            return "no pattern defined yet for a sub-component"
            end
          end
        return cost
        else
        return "no pattern defined yet for a sub-component"
        end
      else
      return calculateBuyingCost(item_id)
      end
    end
  end

  def calculateBuyingCost(item_id)
    item = Item.cached_item(item_id)
    selling_price = item.vendor_selling_price
    buying_price = item.vendor_buying_price
    override_price = PriceOverride.cached_price_override_for_item_for_user(@current_user.id, item_id)
    if (override_price != nil) then
    return override_price.price_per
    else
      if (selling_price != nil) then
      return selling_price
      else if (buying_price != nil) then
        return buying_price
        else
        return "No price defined for item"

        end
      end
    end
  end

  def calculateProfit(listing_id)
    listing = SalesListing.cached_saleslisting(listing_id)
    price_per = listing.price
    stacksize = listing.stacksize

    price = price_per * stacksize
    if price > 0 then
    ah_cut = (price * 0.05).to_i
    deposit_cost = listing.deposit_cost
    minimumCost = minimum_sales_price(SalesListing.cached_saleslisting(listing_id).item_id)
    profit = ((price + deposit_cost) - (minimumCost + ah_cut))
    return profit
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
