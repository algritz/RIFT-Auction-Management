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

  def calculateCraftingCost(id)
    if Item.find(id).is_crafted then
      if CraftedItem.where("crafted_item_generated_id = #{id}").exists? then
        crafting_materials = CraftedItem.find(:all, :conditions => "crafted_item_generated_id = #{id}")
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
    deposit_cost = SalesListing.find(id).deposit_cost
    buyingCost = calculateBuyingCost(SalesListing.find(id).item_id)
    if Item.find(SalesListing.find(id).item_id).is_crafted then
      if CraftedItem.where("crafted_item_generated_id = #{SalesListing.find(id).item_id}").exists? then
        crafting_materials = CraftedItem.find(:all, :conditions => "crafted_item_generated_id = #{SalesListing.find(id).item_id}")
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
      profit = (price - (deposit_cost + cost))
      return profit
      else
        return "no pattern defined yet"
      end
    else
    profit = (price - (deposit_cost + buyingCost ))
    return profit
    end
  end

  def averageSalesPrice(id)
    sold = ListingStatus.find(:all, :conditions => "description ='Sold'").first
    sql_str = "listing_status_id = #{sold.id} and item_id = #{id}"
    price = SalesListing.average(:price, :conditions => sql_str)
    return price.to_i
  end

  def lastSalesPrice(id)
    sold = ListingStatus.find(:all, :conditions => "description ='Sold'").first
    expired = ListingStatus.find(:all, :conditions => "description ='Expired'").first
    sql_str_expired = "listing_status_id = #{expired.id} and item_id = #{id} "
    last_expired_date = SalesListing.find(:all, :conditions => "#{sql_str_expired}").last
    sql_str = "listing_status_id = #{sold.id} and updated_at <= '#{last_expired_date.updated_at}' and item_id = #{id}"
    sold = SalesListing.find(:all, :conditions => sql_str).last
    if sold != nil then
    sql_str_sold = sold.id
    #p sql_str_sold
    #price = SalesListing.find(sql_str_sold)
    #p price
    #return price.to_i
    end
  end

end
