class ParseQueue < ActiveRecord::Base
  attr_accessible :user_id, :content
  def create_delayed
    begin
      file = ParseQueue.first
      file_content = file[:content].split("\n")
      received_substring = "You received:"
      auction_substring = "Auction Created for:"
      auction_price_substring = " You auctioned "
      a_deposit_substring = " for a deposit of "
      crafted_substring = "You have successfully crafted"
      @last_line_parsed = "Start of file process"
      ongoing_listing_status = ListingStatus.cached_listing_status_from_description("Ongoing")
      in_inventory_listing_status = ListingStatus.cached_listing_status_from_description("In Inventory")
      mailed_listing_status = ListingStatus.cached_listing_status_from_description("Mailed")
      crafted_listing_status = ListingStatus.cached_listing_status_from_description("Crafted")
      file_content.each do |line|
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
            sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", ongoing_listing_status[:id], item_id[:id], file[:user_id]], :select => "id, listing_status_id, item_id, user_id")
            # this is an ongoing auction
            if sales_listing != nil then
              # checks if it was already added to the expired list
              previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
              if previously_added == 0 then
              # creates a new Entry to be processed later on
              parsed_auction_line = ParsedAuction.new(:user_id => file[:user_id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "Expired")
              parsed_auction_line.save
              SalesListing.clear_saleslisting_block(nil, file[:user_id], nil)
              SalesListing.clear_saleslisting_block(item_id, file[:user_id], nil)
              SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
              end
            else
            # this is a mailed auction
              sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", mailed_listing_status[:id], item_id[:id], file[:user_id]], :select => "id, listing_status_id, item_id, user_id")
              if sales_listing != nil then
                # checks if it was already added to the mailed list
                previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
                if previously_added == 0 then
                # creates a new Entry to be processed later on
                parsed_auction_line = ParsedAuction.new(:user_id => file[:user_id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "In Inventory")
                parsed_auction_line.save
                SalesListing.clear_saleslisting_block(nil, file[:user_id], nil)
                SalesListing.clear_saleslisting_block(item_id, file[:user_id], nil)
                SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
                end
              else
              #this is a crafted auction
                sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", crafted_listing_status[:id], item_id[:id], file[:user_id]], :select => "id, listing_status_id, item_id, user_id")
                if sales_listing != nil then
                  # checks if it was already added to the mailed list
                  previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
                  if previously_added == 0 then
                  # creates a new Entry to be processed later on
                  parsed_auction_line = ParsedAuction.new(:user_id => file[:user_id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "In Inventory")
                  parsed_auction_line.save
                  SalesListing.clear_saleslisting_block(nil, file[:user_id], nil)
                  SalesListing.clear_saleslisting_block(item_id, file[:user_id], nil)
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
              sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", in_inventory_listing_status[:id], item_id[:id], file[:user_id]], :select => "id, listing_status_id, item_id, user_id")
              if sales_listing != nil then
                # checks if it was already added to the expired list
                previously_added = ParsedAuction.count(:conditions => ["sales_listing_id = ?", sales_listing[:id]])
                if previously_added == 0 then
                # creates a new Entry to be processed later on
                parsed_auction_line = ParsedAuction.new(:user_id => file[:user_id],:sales_listing_id => sales_listing[:id], :item_name => item_name, :action_name => "Relist")
                parsed_auction_line.save
                SalesListing.clear_saleslisting_block(nil, file[:user_id], nil)
                SalesListing.clear_saleslisting_block(item_id, file[:user_id], nil)
                SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
                end
              end
            end
          else
            if line.index(auction_price_substring) != nil then
              full_amount_array = line.split(a_deposit_substring)
              full_name = full_amount_array[0]
              full_name = full_name.split(auction_price_substring)
              full_name = full_name[1]
              full_name = full_name.split(" with ")
              full_name = full_name[0]
              full_amount = full_amount_array[1]
              if full_amount != nil then
                amount_array = full_amount.split(" ")
                silverpos = amount_array.length - 2
                silver = amount_array[silverpos]
                if silver.to_i < 10 then
                silver = "0" + silver
                end
                if amount_array.length >= 4 then
                  goldpos = amount_array.length - 4
                  gold = amount_array[goldpos]
                  if gold.to_i < 10 then
                  gold = "0" + gold
                  end
                end
                if amount_array.length >= 6 then
                platinumpos = amount_array.length - 6
                platinum = amount_array[platinumpos]
                end
                full_price = "#{platinum}#{gold}#{silver}"
                last_parsed_auction = ParsedAuction.all(:conditions => ["user_id = ? and item_name = ?", file[:user_id], full_name])
                if last_parsed_auction != nil then
                  last_parsed_auction.each do |entry|
                    entry.deposit = full_price
                    entry.save
                  end
                end
              end
            end
          end
        end
        @last_line_parsed = line
      end

    rescue => err
    puts "Exception: #{err}"
    err
    end
    file.destroy
    process_parsed
  end
  handle_asynchronously :create_delayed

  def process_parsed
    # fetch possible status
    expired_listing_status = ListingStatus.cached_listing_status_from_description("Expired")
    inventory_listing_status = ListingStatus.cached_listing_status_from_description("In Inventory")
    ongoing_listing_status = ListingStatus.cached_listing_status_from_description("Ongoing")

    # fetch auctions to parse
    parse_list = ParsedAuction.all(:order => "id")

    # with every auctions to parse
    parse_list.each do |auction|
    # if they should expire
      case auction[:action_name]
      when "Expired"
        sales_listing = SalesListing.find(:first, :conditions => ["id = ?", auction[:sales_listing_id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
        if sales_listing.relisted_status != true then
        sales_relisting = SalesListing.new(:item_id => sales_listing.item_id,
        :stacksize => sales_listing.stacksize,
        :deposit_cost => sales_listing.deposit_cost,
        :listing_status_id => inventory_listing_status[:id],
        :price => lastSalesPrice(sales_listing.item_id, auction[:user_id]),
        :is_undercut_price => lastIsUndercutPrice(sales_listing, auction[:user_id]),
        :user_id => auction[:user_id])

        sales_listing.listing_status_id = expired_listing_status[:id]
        sales_listing.relisted_status = true
        sales_listing.save
        sales_relisting.save
        parsed_auction = ParsedAuction.find(auction[:id])
        parsed_auction.destroy
        SalesListing.clear_saleslisting_block(nil, auction[:user_id], nil)
        SalesListing.clear_saleslisting_block(sales_listing.item_id, auction[:user_id], nil)
        SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
        end
      # if they should be relisted
      when "Relist"
        sales_listing = SalesListing.find(:first, :conditions => ["id = ?", auction[:sales_listing_id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
        sales_listing.listing_status_id = ongoing_listing_status[:id]
        sales_listing.save
        parsed_auction = ParsedAuction.find(auction[:id])
        parsed_auction.destroy
        SalesListing.clear_saleslisting_block(nil, auction[:user_id], nil)
        SalesListing.clear_saleslisting_block(sales_listing.item_id, auction[:user_id], nil)
        SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])

      when "In Inventory"
        sales_listing = SalesListing.find(:first, :conditions => ["id = ?", auction[:sales_listing_id]], :select => "id, user_id, profit, listing_status_id, item_id, stacksize, deposit_cost, price, relisted_status")
        sales_listing.listing_status_id = inventory_listing_status[:id]
        sales_listing.save
        parsed_auction = ParsedAuction.find(auction[:id])
        parsed_auction.destroy
        SalesListing.clear_saleslisting_block(nil, auction[:user_id], nil)
        SalesListing.clear_saleslisting_block(sales_listing.item_id, auction[:user_id], nil)
        SalesListing.clear_saleslisting_block(nil, nil, sales_listing[:id])
      end
    # end of parse_list.each
    end

  # end of process_parsed
  end


  def lastSalesPrice(item_id, user_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description('Sold')
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold = SalesListing.cached_last_sold_auction(sold_status[:id], item_id, user_id)
      last_sold_date = SalesListing.cached_last_sold_date(sold_status[:id], item_id, user_id)
      expired_listing = SalesListing.cached_expired_listing(expired_status[:id], item_id, user_id)

      if sold != nil then
        if (sold.updated_at == last_sold_date.updated_at) then
        price = (sold.price * 1.1).round
        else
        price = sold.price
        end
      else if expired_listing != nil then
          if last_sold_date != nil then
          @number_of_expired = SalesListing.cached_expired_count(expired_status[:id], item_id, user_id, last_sold_date.updated_at)
          else
          @number_of_expired = SalesListing.cached_expired_count_overall(expired_status[:id], item_id, user_id)

          end
          if @number_of_expired.modulo(5) == 0 then
          price = (expired_listing.price * 0.97).round
          else
          price = expired_listing.price
          end
        else
          listed_but_not_sold = SalesListing.cached_listed_but_not_sold(expired_status[:id], item_id, user_id)
          if listed_but_not_sold != nil then
          price = listed_but_not_sold.price
          else
          price = 0
          end
        end
      end
    end
  end

  def lastDepositCost(item_id, user_id)
    if item_id != nil then
      SalesListing.last(:select => 'deposit_cost', :conditions => ["item_id = ? and user_id = ?", item_id, user_id]).to_i
    end
  end

  # this method is also present in the application helper, so any bug found there is likely to happen here
  def lastIsUndercutPrice(item_id, user_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description("Sold")
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold_not_undercut = SalesListing.cached_sold_not_undercut_count(item_id, user_id, sold_status[:id])
      expired_not_undercut = SalesListing.cached_expired_not_undercut_count(item_id, user_id, expired_status[:id])
      sold_and_undercut = SalesListing.cached_sold_and_undercut_count(item_id, user_id, sold_status[:id])
      expired_and_undercut = SalesListing.cached_expired_and_undercut_count(item_id, user_id, expired_status[:id])

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


# end of model
end
