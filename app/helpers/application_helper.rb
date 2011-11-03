module ApplicationHelper
  def getSourceDescription (source_id)
    if source_id != nil then
    #using cached results yields similar results as non-cached, but in order to save on DB I/O, we use cache
    Source.cached_source(source_id).description
    else
    "Unknown source"
    end
  end

  def getItemDescription (item_id)
    # using cache provides a significant performance gain
    item = Item.cached_item(item_id).description
  end

  def getItemDescriptionFromKey (itemkey)
    # using cache provides a slight performance gain
    item = Item.cached_item_from_key(itemkey).description
  end

  def getCompetitorStyleDescription (style_id)
    #using cached results yields similar results as non-cached, but in order to save on DB I/O, we use cache
    CompetitorStyle.cached_competitor_style(style_id).description
  end

  def getListingStatusDescription(listing_status_id)
    #using cached results yields similar results as non-cached, but in order to save on DB I/O, we use cache
    ListingStatus.cached_listing_status(listing_status_id).description
  end

  def getItemRarity(item_id)
    # using cache provides a significant performance gain
    Item.cached_item(item_id).rarity
  end

  def getItemRequiredLevel(item_id)
    # using cache provides a significant performance gain
    Item.cached_item(item_id).item_level
  end

  def getToonName(toon_id)
    #using cached results yields similar results as non-cached, but in order to save on DB I/O, we use cache
    Toon.cached_toon(toon_id).name
  end

  def getSourceDescriptionForItemsToCraft (item_id)
    #using cached results yields similar results as non-cached, but in order to save on DB I/O, we use cache
    source = Rails.cache.fetch("ItemToCraft.#{item_id}.cached_item_source_description")
    if source == nil then
      source = CraftedItem.cached_source_description_for_crafted_item(item_id)
      if source == nil then
      source = "Source Unclear"
      else
      Rails.cache.write("ItemToCraft.#{item_id}.cached_item_source_description", source)
      end
    end
    return source.required_skill
  end

  def isNewRow(someID)
    if @lastIDRow != someID then
      @lastIDRow = someID
      @isNewRow = true
      if @lastRowColor == "#ffffff" or @lastRowColor == nil then
      @lastRowColor = "#e3e3e3"
      else
      @lastRowColor = "#ffffff"
      end
    else
    @isNewRow = false
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

  def checkIfProfit(listing_id)
    sold = ListingStatus.cached_listing_status_from_description("Sold")
    expired = ListingStatus.cached_listing_status_from_description("Expired")
    auction = SalesListing.cached_profit(listing_id)
    if auction[:listing_status_id] == sold[:id] then
    auction.profit
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

  def averageSalesPrice(item_id)
    if item_id != nil then
    sold = ListingStatus.cached_listing_status_from_description('Sold')
    price = SalesListing.cached_average_selling_price(item_id, current_user.id, sold.id)
    return price.to_i
    end
  end

  # this method is also present in SalesListing controller in the private method section, so any bug found
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
          @number_of_expired = SalesListing.cached_expired_count_overall(expired_status[:id], item_id, false, current_user.id)

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

  def lastSalesPrice_without_listed(item_id)
    if item_id != nil then
      sold =  @lastSalesPrice_without_listed = SalesListing.cached_lastSalesPrice_without_listed(item_id, current_user.id)
      if sold == nil then
      @lastSalesPrice_without_listed = SalesListing.cached_lastSalesPrice_without_listed_including_undercut(item_id, current_user.id)
      end
    end

  end

  # this method is also present in the SalesListing controller, so any bug found there is likely to happen here
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

  def lastListings(item_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description("Sold")
      last_sold = SalesListing.cached_last_sold_date(sold_status[:id], item_id, current_user.id)
      if last_sold != nil then
      lastListings = SalesListing.cached_sales_listing_per_status_count(item_id, current_user.id, last_sold.updated_at)
      else
      lastListings = SalesListing.cached_sales_listing_per_status_overall_count(item_id, current_user.id)
      end
    end
  end

  def is_relistable?(sales_listing)
    ((ListingStatus.cached_listing_status(sales_listing.listing_status_id).description == 'In Inventory' || ListingStatus.cached_listing_status(sales_listing.listing_status_id).description == 'Mailed')&& sales_listing.price != nil)
  end

  def is_final?(status_id)
    ListingStatus.cached_listing_status(status_id).is_final
  end

  def is_mailed?(status_id)
    ListingStatus.cached_listing_status(status_id).description == 'Crafted'
  end

  def is_ongoing?(status_id)
    ListingStatus.cached_listing_status(status_id).description == 'Ongoing'
  end

  def sales_percentage_full_price(item_id)
    total_auctions_full_price = SalesListing.cached_sales_percentage_full_price(item_id, current_user[:id])
    sold_auctions = SalesListing.sold_auctions_cached_for_user(item_id, current_user[:id])
    percentage = (sold_auctions.to_f / total_auctions_full_price.to_f) * 100
    percentage = format("%.2f",percentage)
    if percentage == "NaN" then
    percentage = "Never Sold "
    else
    percentage = "#{format("%.2f",percentage)}%"
    end
  end

  def sales_percentage_undercut(item_id)
    total_auctions = SalesListing.sold_auctions_including_undercut_cached_for_user(item_id, current_user[:id])
    sold_auctions = SalesListing.cached_sales_percentage_undercut_price(item_id, current_user[:id])
    percentage = (sold_auctions.to_f / total_auctions.to_f) * 100
    percentage = format("%.2f",percentage)
    if percentage == "NaN" then
    percentage = "Never Sold"
    else
    percentage = "#{format("%.2f",percentage)}%"
    end
  end

  def sales_percentage_overall(item_id)
    total_auctions_overall = SalesListing.cached_total_auctions_overall(item_id, current_user[:id])
    sold_auctions = SalesListing.cached_sold_auctions_overall(item_id, current_user[:id])
    percentage = (sold_auctions.to_f / total_auctions_overall.to_f) * 100
    percentage = format("%.2f",percentage)
    if percentage == "NaN" then
    percentage = "Never Sold"
    else
    percentage = "#{format("%.2f",percentage)}%"
    end
  end

  def minimum_sales_price(item_id)
    if item_id != nil then
      crafting_cost = calculateCraftingCost(item_id)
      if crafting_cost.class == String then
      return crafting_cost
      end
      deposit_cost = SalesListing.cached_maximum_deposit_cost_for_item(item_id, current_user[:id])
      if deposit_cost == nil then
      deposit_cost = 0
      end
      sold_status = ListingStatus.cached_listing_status_from_description("Sold")
      ever_sold = SalesListing.cached_last_sold_auction(sold_status, item_id, current_user[:id])
      if ever_sold != nil then
        last_sold_date = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", sold_status, item_id, current_user[:id]], :select => "id, listing_status_id, item_id, user_id, updated_at")
        number_of_relists_since_last_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and sales_listings.updated_at > ? and user_id = ?", item_id, "Expired", last_sold_date, current_user.id])
        if number_of_relists_since_last_sold > 0 then
        minimum_price = ((number_of_relists_since_last_sold * deposit_cost) + crafting_cost)
        else
        minimum_price = (deposit_cost + crafting_cost)
        end
      else
        number_of_relists = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:id, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Expired", current_user.id])
        if number_of_relists > 0 then
        minimum_price = ((number_of_relists * deposit_cost) + crafting_cost)
        else
        minimum_price = (deposit_cost + crafting_cost)
        end
      end
    end
  end

  def get_cache_stats
    @stats = Rails.cache.stats.first.last
  end

  require 'will_paginate/collection'
  Array.class_eval do
    def paginate(options = {})
      raise ArgumentError, "parameter hash expected (got #{options.inspect})" unless Hash === options

      WillPaginate::Collection.create(
      options[:page] || 1,
      options[:per_page] || 30,
      options[:total_entries] || self.length
      ) { |pager|
        pager.replace self[pager.offset, pager.per_page].to_a
      }
    end
  end

end
