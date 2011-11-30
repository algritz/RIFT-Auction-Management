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
      @last_line_parsed = nil
      ongoing_listing_status = ListingStatus.cached_listing_status_from_description("Ongoing")
      expired_listing_status = ListingStatus.cached_listing_status_from_description("Expired")
      inventory_listing_status = ListingStatus.cached_listing_status_from_description("In inventory")

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
            # fetch active listings
            sales_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", ongoing_listing_status[:id], item_id[:id], current_user[:id]])

            if sales_listing != nil then
              previously_added = ParsedAuction.count(sales_listing[:id])
              if  previously_added == 0  then
              parsed_auction_line = ParsedAuction.new(:user_id => current_user[:id],:sales_listing_id => sales_listing[:id], :item_name => item_name)
              p parsed_auction_line
              parsed_auction_line.save
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

  #@parsed_auction.save
  #if @parsed_auction.save
  #flash[:notice] = "Successfully created parsed auctions."
  #@parsed_auctions = ParsedAuction.all
  #end
  end

  # DELETE /parsed_auctions/1l
  # DELETE /parsed_auctions/1.json
  def destroy
    @parsed_auction = ParsedAuction.find(params[:id])
    @parsed_auction.destroy
    flash[:notice] = "Successfully destroyed parsed auctions."
    @parsed_auctions = ParsedAuction.all
  end
end
