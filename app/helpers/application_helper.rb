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

  def determineDefaultStacksize(f, id)
    p "test"
    if id != nil then
      if Item.find(id).is_crafted then
        #return CraftedItem.find(id).stacksize
        f.text_field :stacksize, :value=> CraftedItem.find(id).stacksize
        p"should change to #{CraftedItem.find(id).stacksize} "
      else
      #return 1
        f.text_field :stacksize, :value=> 1
      end
    else
    return 1
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
      return "#{id} is Crafted"
    else
      return formatPrice(calculateBuyingCost(id))
    end
  end

  def calculateBuyingCost(id)
    selling_price = Item.find(id).vendor_selling_price
    buying_price = Item.find(id).vendor_buying_price

    if (selling_price != nil) then
    return selling_price
    else
    return buying_price
    end
  end

  def calculateProfit(id)
    price = SalesListing.find(id).price
    deposit_cost = SalesListing.find(id).deposit_cost
    vendor_price = calculateBuyingCost(SalesListing.find(id).item_id)
    if Item.find(SalesListing.find(id).item_id).is_crafted then
      if CraftedItem.where("crafted_item_generated_id = #{SalesListing.find(id).item_id}").exists? then
        crafting_cost = CraftedItem.where("crafted_item_generated_id = #{SalesListing.find(id).item_id}")
        p crafting_cost
      #return profit = (price - (deposit_cost + vendor_price))
      else
        return "no pattern defined yet"
      end
    else
    return profit = (price - (deposit_cost + vendor_price))
    end
  end

end
