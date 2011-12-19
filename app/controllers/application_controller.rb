class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  before_filter :init
  def init
    @start_time = Time.now
  end

  def my_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/my.log")
  end

  def lastSalesPrice(item_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description('Sold')
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold = SalesListing.cached_last_sold_auction(sold_status[:id], item_id, current_user[:id])
      last_sold_date = SalesListing.cached_last_sold_date(sold_status[:id], item_id, current_user[:id])
      expired_listing = SalesListing.cached_expired_listing(expired_status[:id], item_id, current_user[:id])

      if sold != nil then
        if (sold[:id] == last_sold_date[:id]) then
        price = (sold[:price] * 1.1).round
        else
        price = sold[:price]
        end
      else if expired_listing != nil then
          if last_sold_date != nil then
          @number_of_expired = SalesListing.cached_expired_count(expired_status[:id], item_id, current_user[:id], last_sold_date[:updated_at])
          else
          @number_of_expired = SalesListing.cached_expired_count_overall(expired_status[:id], item_id, current_user[:id])

          end
          if @number_of_expired.modulo(5) == 0 then
          price = (expired_listing[:price] * 0.97).round
          else
          price = expired_listing[:price]
          end
        else
          listed_but_not_sold = SalesListing.cached_listed_but_not_sold(expired_status[:id], item_id, current_user[:id])
          if listed_but_not_sold != nil then
          price = listed_but_not_sold[:price]
          else
          price = 0
          end
        end
      end
    end
  end

  def lastDepositCost(item_id)
    if item_id != nil then
      cost = SalesListing.last(:select => 'deposit_cost', :conditions => ["item_id = ? and user_id = ?", item_id, current_user[:id]])
    cost = cost[:deposit_cost].to_i
    end
  end

  # this method is also present in the application helper, so any bug found there is likely to happen here
  def lastIsUndercutPrice(item_id)
    if item_id != nil then
      sold_status = ListingStatus.cached_listing_status_from_description("Sold")
      expired_status = ListingStatus.cached_listing_status_from_description('Expired')
      sold_not_undercut = SalesListing.cached_sold_not_undercut_count(item_id, current_user[:id], sold_status[:id])
      expired_not_undercut = SalesListing.cached_expired_not_undercut_count(item_id, current_user[:id], expired_status[:id])
      sold_and_undercut = SalesListing.cached_sold_and_undercut_count(item_id, current_user[:id], sold_status[:id])
      expired_and_undercut = SalesListing.cached_expired_and_undercut_count(item_id, current_user[:id], expired_status[:id])

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
      deposit_cost = SalesListing.cached_last_deposit_cost_for_item(item_id, current_user[:id])
      if deposit_cost == nil then
      deposit_cost = 0
      end
      ever_sold = SalesListing.cached_sold_count_for_item(item_id, current_user[:id])
      if ever_sold > 0 then
        ## last_sold_date performs better without cache when called repeatedly
        last_sold_date = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", current_user[:id]], :select => "sales_listings.id, item_id, listing_statuses.description, user_id, sales_listings.updated_at").last.updated_at
        number_of_relists_since_last_sold = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and sales_listings.updated_at > ? and user_id = ?", item_id, "Expired", last_sold_date, current_user[:id]])
        if number_of_relists_since_last_sold > 0 then
          deposit_amount = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").sum(:deposit_cost, :conditions => ["item_id = ? and listing_statuses.description = ? and sales_listings.updated_at > ? and user_id = ?", item_id, "Expired", last_sold_date, current_user[:id]])
        minimum_price = (deposit_amount + crafting_cost)
        else
        minimum_price = (deposit_cost + crafting_cost)
        end
      else
        number_of_relists = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Expired", current_user[:id]])
        if number_of_relists > 0 then
          deposit_amount = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").sum(:deposit_cost, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Expired", current_user[:id]])
        minimum_price = ((deposit_amount) + crafting_cost)
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
    override_price = PriceOverride.cached_price_override_for_item_for_user(@current_user[:id], item_id)
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
