module ApplicationHelper
  def getSourceDescription (id)
    Source.find(id).description
  end

  def getItemDescription (id)
    Item.find(id).description
  end

  def getCompetitorStyleDescription (id)
    CompetitorStyle.find(id).description
  end

  def getListingStatusDescription(id)
    ListingStatus.find(id).description
  end

  def getSourceDescriptionForItemsToCraft (id)
    Source.find(Item.find(id).source_id).description
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
  end

  def calculateCraftingCost(id)
    if id != nil then
      if Item.find(id).is_crafted then
        if CraftedItem.where(["crafted_item_generated_id = ?", id]).exists? then
          crafting_materials = CraftedItem.find(:all, :conditions => ["crafted_item_generated_id = ?", id])
          cost = 0
          crafting_materials.each do |materials|
            material_cost = calculateCraftingCost(materials.component_item_id)
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
    selling_price = Item.find(id).vendor_selling_price
    buying_price = Item.find(id).vendor_buying_price

    if (selling_price != nil) then
    return selling_price
    else if (buying_price != nil) then
      return buying_price
      else
        return "No price defined for item"
      end
    end
  end

  def calculateProfit(id)
    price = SalesListing.find(id).price
    if price > 0 then
      ah_cut = (price * 0.05).to_i

      deposit_cost = SalesListing.find(id).deposit_cost
      buyingCost = calculateBuyingCost(SalesListing.find(id).item_id)
      if Item.find(SalesListing.find(id).item_id).is_crafted then
        if CraftedItem.where(["crafted_item_generated_id = ?", SalesListing.find(id).item_id]).exists? then
          crafting_materials = CraftedItem.find(:all, :conditions => ["crafted_item_generated_id = ?", SalesListing.find(id).item_id])
          cost = 0
          crafting_materials.each do |materials|
            material_cost = calculateCraftingCost(materials.component_item_id)
            total_material_cost = (material_cost * materials.component_item_quantity)
            if (material_cost.to_s != "no pattern defined yet for a sub-component") then
            cost += total_material_cost
            else
              return "no pattern defined yet for a sub-component"
            end
          end
        profit = ((price + deposit_cost )- (cost + ah_cut))
        return profit
        else
          return "no pattern defined yet"
        end
      else
      profit = ((price + deposit_cost) - (buyingCost + ah_cut))
      return profit
      end
    end
  end

  def averageSalesPrice(id)
    if id != nil then
      sold = ListingStatus.find(:all, :conditions => "description ='Sold'").first
      price = SalesListing.average(:price, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", sold.id, id, false])
    return price.to_i
    end
  end

  # this method is also present in SalesListing controller in the private method section, so any bug found
  # in this block is likely to happen over there
  def lastSalesPrice(id)
    if id != nil then
      sold_status = ListingStatus.find(:all, :conditions => "description ='Sold'").first
      expired = ListingStatus.find(:all, :conditions => "description ='Expired'").first
      sold = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", sold_status.id, id, false]).last
      last_sold_date = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? ", sold_status.id, id]).last
      expired_listing = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", expired.id, id, false]).last
      if sold != nil then
        if sold.updated_at == last_sold_date.updated_at then
          sold_id = sold.id
          price = (SalesListing.find(sold_id).price * 1.1).round
        else
          sold_id = sold.id
          price = SalesListing.find(sold_id).price
        end
      else if expired_listing != nil then
          if last_sold_date != nil then
            @number_of_expired = SalesListing.count(:conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and updated_at < ?", expired.id, id, false, last_sold_date.updated_at] )
          else
            @number_of_expired = SalesListing.count(:conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", expired.id, id, false] )
          end
          if @number_of_expired.modulo(5) == 0 then
            expired_id = expired_listing.id
            price = (SalesListing.find(expired_id).price * 0.97).round
          else
            expired_id = expired_listing.id
            price = SalesListing.find(expired_id).price
          end
        else
          listed_but_not_sold = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", expired.id, id, false]).last
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
      sold =  @lastSalesPrice_without_listed = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ?", id, false, "Sold"]).last
      if sold == nil then
        @lastSalesPrice_without_listed = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ?", id, true, "Sold"]).last
      end
    end
  end

  # this method is also present in the SalesListing controller, so any bug found there is likely to happen here
  def lastIsUndercutPrice(id)
    if id != nil then
      sold_status = ListingStatus.find(:all, :conditions => "description ='Sold'").first
      expired = ListingStatus.find(:all, :conditions => "description ='Expired'").first
      sold_not_undercut = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", sold_status.id, id, false]).last
      expired_not_undercut = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", expired.id, id, false]).last
      sold_and_undercut = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", sold_status.id, id, true]).last
      expired_and_undercut = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", expired.id, id, true]).last

      if sold_not_undercut != nil then
      is_undercut_price = false
      else if expired_not_undercut != nil then
        is_undercut_price = false
        else if sold_and_undercut != nil then
          is_undercut_price = true
          else if expired_and_undercut != nil then
            is_undercut_price = true
            end
          end
        end
      end
    end
  end

  def lastListings(id)
    if id != nil then
      sold = ListingStatus.find(:all, :conditions => "description ='Sold'").first
      last_sold = SalesListing.find(:all, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ?", sold.id, id, false], :order => "updated_at desc").first
      if last_sold != nil then
        lastListings = SalesListing.count(:all, :conditions => ["item_id = ? and updated_at >= ? and is_undercut_price = ?", id, last_sold.updated_at, false], :group => 'listing_status_id')
      else
        lastListings = SalesListing.count(:all, :conditions => ["item_id = ? and is_undercut_price = ?", id, false], :group => 'listing_status_id')
      end
      lastListings_per_status = []
      lastListings.each do |status, value|
        lastListings_per_status << "#{getListingStatusDescription(status)} : #{value} <br />"
      end
    return lastListings_per_status
    end
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
    total_auctions_full_price = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.is_final = ?", item_id, false, true])
    sold_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ?", item_id, false, "Sold"])
    percentage = (sold_auctions.to_f / total_auctions_full_price.to_f) * 100
    format("%.2f",percentage)
  end

  def sales_percentage_undercut(item_id)
    total_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.is_final = ?", item_id, true, true])
    sold_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ?", item_id, true, "Sold"])
    percentage = (sold_auctions.to_f / total_auctions.to_f) * 100
    format("%.2f",percentage)
  end

  def sales_percentage_overall(item_id)
    total_auctions_overall = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.is_final = ?", item_id, true])
    sold_auctions = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ?", item_id, "Sold"])
    percentage = (sold_auctions.to_f / total_auctions_overall.to_f) * 100
    format("%.2f",percentage)
  end

  def minimum_sales_price(item_id)
    if item_id != nil then
      crafting_cost = calculateCraftingCost(item_id)
      deposit_cost = SalesListing.maximum("deposit_cost", :conditions => ["item_id = ?", item_id])
      if deposit_cost == nil then
        deposit_cost = 0
      end
      ever_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and listing_statuses.description = ?", item_id, "Sold"]).last
      if ever_sold != nil then
        last_sold_date = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and listing_statuses.description = ?", item_id, "Sold"]).last.updated_at
        number_of_relists_since_last_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and sales_listings.updated_at > ?", item_id, "Expired", last_sold_date])  
        if number_of_relists_since_last_sold > 0 then
          minimum_price = formatPrice(((number_of_relists_since_last_sold * deposit_cost) + crafting_cost))
        else
          minimum_price = formatPrice((deposit_cost + crafting_cost))
        end
      else
        number_of_relists = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ?", item_id, "Expired"])
        if number_of_relists > 0 then
          minimum_price = formatPrice(((number_of_relists * deposit_cost) + crafting_cost))
        else
          minimum_price = formatPrice((deposit_cost + crafting_cost))
        end
      end
    end
  end

end
