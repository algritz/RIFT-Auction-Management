module ApplicationHelper
  def getSourceDescription (id)
    if id != nil then
      Source.find(:first, :conditions => ["id = ?", id], :select => "id, description").description
    else
      "Unknown source"
    end
  end

  def getItemDescription (id)
    item = Item.find(:first, :conditions => ["id = ?", id], :select => "id, description").description
  end

  def getItemDescriptionFromKey (itemkey)
    item = Item.find(:first, :conditions => ["ItemKey = ?", itemkey], :select => "id, description, itemkey").description
  end

  def getCompetitorStyleDescription (id)
    CompetitorStyle.find(:first, :conditions => ["id = ?", id], :select => "id, description").description
  end

  def getListingStatusDescription(id)
    ListingStatus.find(:first, :conditions => ["id = ?", id], :select => "id, description").description
  end

  def getItemRarity(id)
    Item.find(id).rarity
  end

  def getItemRequiredLevel(id)
    Item.find(id).item_level
  end

  def getToonName(id)
    Toon.find(:first, :conditions => ["id = ?", id], :select =>["id, name"]).name
  end

  def getSourceDescriptionForItemsToCraft (id)
    source = CraftedItem.joins("left join items on items.itemkey = crafted_items.crafted_item_generated_id").find(:first, :conditions => ["items.id = ?", id])
    if source == nil then
      source = "Source Unclear"
    else
    source = source.required_skill
    end
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

  def calculateCraftingCost(id)
    if id != nil then
      item = Item.find(:first, :conditions => ["id = ?", id], :select => "id, is_crafted, itemkey")
      if item.is_crafted then
        if CraftedItem.count(:id, :conditions=> ["crafted_item_generated_id = ?", item.itemkey], :select => "id, crafted_item_generated_id") > 0 then
          crafting_materials = CraftedItem.find(:all, :conditions => ["crafted_item_generated_id = ?", item.itemkey], :select => "id, crafted_item_generated_id, component_item_id, component_item_quantity")
          cost = 0
          crafting_materials.each do |materials|
            component = Item.find(:first, :conditions => ["itemkey = ?", materials.component_item_id], :select => "id, itemkey")
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
        return calculateBuyingCost(id)
      end
    end
  end

  def calculateBuyingCost(id)
    item = Item.find(:first, :conditions => ["id = ?", id], :select => "id, vendor_selling_price, vendor_buying_price")
    selling_price = item.vendor_selling_price
    buying_price = item.vendor_buying_price
    override_price = PriceOverride.find(:first, :conditions => ["user_id = ? and item_id = ?", @current_user.id, item[:id]], :select => "id, user_id, item_id, price_per")
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

  def checkIfProfit(id)
    sold = ListingStatus.find(:all, :conditions => ["description = ?", 'Sold'], :select => "id, description").first
    expired = ListingStatus.find(:all, :conditions => ["description = ?", 'Expired'], :select => "id, description").first
    auction = SalesListing.find(:first, :conditions => ["id = ?", id], :select => "id, listing_status_id, profit")
    if auction.listing_status_id == sold.id then
    auction.profit
    end
  end

  def calculateProfit(id)
    price = SalesListing.find(id).price
    if price > 0 then
      ah_cut = (price * 0.05).to_i
      deposit_cost = SalesListing.find(id).deposit_cost
      minimumCost = minimum_sales_price(SalesListing.find(item).item_id)
    profit = ((price + deposit_cost) - (minimumCost + ah_cut))
    return profit
    end
  end

  def averageSalesPrice(id)
    if id != nil then
      sold = ListingStatus.find(:all, :conditions => ["description = ?", 'Sold'], :select => "id, description").first
      price = SalesListing.average(:price, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold.id, id, false, current_user.id])
    return price.to_i
    end
  end

  # this method is also present in SalesListing controller in the private method section, so any bug found
  # in this block is likely to happen over there
  def lastSalesPrice(id)
    if id != nil then
      sold_status = ListingStatus.find(:first, :conditions => ["description = ?", 'Sold'], :select => "id, description")
      expired = ListingStatus.find(:first, :conditions => ["description = ?", 'Expired'], :select => "id, description")
      sold = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status.id, id, false, current_user.id], :select => "id, listing_status_id, item_id, is_undercut_price, user_id, price, updated_at")
      last_sold_date = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", sold_status.id, id, current_user.id], :select => "id, listing_status_id, item_id, user_id, updated_at")
      expired_listing = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user.id], :select => "id, listing_status_id, item_id, is_undercut_price, user_id, price, updated_at")
      if sold != nil then
        if (sold.updated_at == last_sold_date.updated_at) then
        price = (sold.price * 1.1).round
        else
        price = sold.price
        end
      else if expired_listing != nil then
          if last_sold_date != nil then
            @number_of_expired = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and updated_at < ? and user_id = ?", expired.id, id, false, last_sold_date.updated_at, current_user.id] )
          else
            @number_of_expired = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user.id] )
          end
          if @number_of_expired.modulo(5) == 0 then
          price = (expired_listing.price * 0.97).round
          else
          price = expired_listing.price
          end
        else
          listed_but_not_sold = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user.id], :select => "id, price, listing_status_id, item_id, is_undercut_price, user_id")
          if listed_but_not_sold != nil then
          price = listed_but_not_sold.price
          else
          price = 0
          end
        end
      end
    end
  end

  def lastSalesPrice_without_listed(id)
    if id != nil then
      sold =  @lastSalesPrice_without_listed = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", id, false, "Sold", current_user]).last
      if sold == nil then
        @lastSalesPrice_without_listed = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", id, true, "Sold", current_user]).last
      end
    end
  end

  # this method is also present in the SalesListing controller, so any bug found there is likely to happen here
  def lastIsUndercutPrice(id)
    if id != nil then
      sold_status = ListingStatus.find(:all, :conditions => ["description = ?", 'Sold'], :select => "id, description").first
      expired = ListingStatus.find(:all, :conditions => ["description = ?", 'Expired'], :select => "id, description").first
      sold_not_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status.id, id, false, current_user[:id]])
      expired_not_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, false, current_user[:id]])
      sold_and_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status.id, id, true, current_user[:id]])
      expired_and_undercut = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired.id, id, true, current_user[:id]])

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

  def lastListings(id)
    if id != nil then
      sold = ListingStatus.find(:first, :conditions => ["description = ?", 'Sold'], :select => "id, description")
      last_sold = SalesListing.find(:first, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold.id, id, false, current_user.id], :order => "updated_at desc", :select => "id, item_id, user_id, is_undercut_price, listing_status_id, updated_at")
      if last_sold != nil then
        lastListings = SalesListing.count(:id, :conditions => ["item_id = ? and updated_at >= ? and is_undercut_price = ? and user_id = ?", id, last_sold.updated_at, false, current_user.id], :group => 'listing_status_id')
      else
        lastListings = SalesListing.count(:id, :conditions => ["item_id = ? and is_undercut_price = ? and user_id = ?", id, false, current_user.id], :group => 'listing_status_id')
      end
    end
  end

  def is_relistable?(sales_listing)
    (ListingStatus.find(sales_listing.listing_status_id).description == 'In Inventory' || ListingStatus.find(sales_listing.listing_status_id).description == 'Mailed') && sales_listing.price > 0
  end

  def is_final?(status_id)
    ListingStatus.find(status_id).is_final
  end

  def is_mailed?(status_id)
    ListingStatus.find(status_id).description == 'Crafted'
  end

  def is_ongoing?(status_id)
    ListingStatus.find(status_id).description == 'Ongoing'
  end

  def sales_percentage_full_price(item_id)
    total_auctions_full_price = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.is_final = ? and user_id = ?", item_id, false, true, current_user.id])
    sold_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", item_id, false, "Sold", current_user.id])
    percentage = (sold_auctions.to_f / total_auctions_full_price.to_f) * 100
    percentage = format("%.2f",percentage)
    if percentage == "NaN" then
      percentage = "Never Sold "
    else
      percentage = "#{format("%.2f",percentage)}%"
    end
  end

  def sales_percentage_undercut(item_id)
    total_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.is_final = ? and user_id = ?", item_id, true, true, current_user.id])
    sold_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", item_id, true, "Sold", current_user.id])
    percentage = (sold_auctions.to_f / total_auctions.to_f) * 100
    percentage = format("%.2f",percentage)
    if percentage == "NaN" then
      percentage = "Never Sold"
    else
      percentage = "#{format("%.2f",percentage)}%"
    end
  end

  def sales_percentage_overall(item_id)
    total_auctions_overall = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:id, :conditions => ["item_id = ? and listing_statuses.is_final = ? and user_id = ?", item_id, true, current_user.id])
    sold_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:id, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", current_user.id])
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
      deposit_cost = SalesListing.maximum("deposit_cost", :conditions => ["item_id = ? and user_id = ?", item_id, current_user.id])
      if deposit_cost == nil then
      deposit_cost = 0
      end
      ever_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:id, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", current_user.id])
      if ever_sold > 0 then
        last_sold_date = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", current_user.id], :select => "sales_listings.id, item_id, listing_statuses.description, user_id, sales_listings.updated_at").last.updated_at
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
  
end
