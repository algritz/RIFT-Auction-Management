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
  end
  handle_asynchronously :create_delayed

end
