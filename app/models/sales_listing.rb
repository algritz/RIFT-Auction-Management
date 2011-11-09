class SalesListing < ActiveRecord::Base
  attr_accessible :item_id, :stacksize, :price, :is_undercut_price, :deposit_cost, :listing_status_id, :user_id, :is_tainted
  attr_accessor :every_items
  validates :item_id, :presence => true
  validates_numericality_of :item_id
  validates :stacksize, :presence => true
  validates_numericality_of :stacksize
  validates :deposit_cost, :presence => true
  validates_numericality_of :deposit_cost, :allow_nil => true
  validates :listing_status_id, :presence => true
  validates_numericality_of :listing_status_id
  validates_numericality_of :price, :allow_nil => true

  cattr_reader :per_page
  @@per_page = 20
  def self.search(search, page)
    paginate :per_page => 20, :page => page,
    :joins => ("left join items on items.id = sales_listings.item_id"),
    :conditions => ['items.description like ?', "%#{search}%"], :order => "items.description, sales_listings.updated_at desc"
  end

  ## cache section, series of handlers related to cache in order to help performance
  def self.average_profit_cached_for_user(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.average_profit_cached_for_user")
    if data == nil then
      data = SalesListing.average(:profit, :conditions => ["item_id = ? and user_id = ?", item_id, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.average_profit_cached_for_user", data)
    end
    return data
  end

  def self.sold_auctions_cached_for_user(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.sold_auctions_cached_for_user")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", item_id, false, "Sold", user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.sold_auctions_cached_for_user", data)
    end
    return data
  end

  def self.sold_auctions_including_undercut_cached_for_user(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.sold_auctions_including_undercut_cached_for_user")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.is_final = ? and user_id = ?", item_id, true, true, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.sold_auctions_including_undercut_cached_for_user", data)
    end
    return data
  end

  def self.ongoing_listing_count_cached_for_user(user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.ongoing_listing_count_cached_for_user")
    if data == nil then
      data = SalesListing.find_by_sql(["select distinct item_id from sales_listings where user_id = ? and listing_status_id not in (5,1)", user_id])
    Rails.cache.write("SalesListings.#{user_id}.ongoing_listing_count_cached_for_user", data)
    end
    return data
  end

  def self.active_auctions_cached_for_user(item_id, sold_id, expired_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.active_auctions_cached_for_user")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["item_id = ? and listing_status_id not in (?, ?) and user_id = ?", item_id, sold_id, expired_id, user_id])
    Rails.cache.write("SalesListings.#{user_id}.active_auctions_cached_for_user", data)
    end
    return data
  end

  def self.cached_saleslisting(listing_id)
    data = Rails.cache.fetch("SalesListings.#{listing_id}.cached_saleslisting")
    if data == nil then
    data = SalesListing.find(listing_id, :select => "id, item_id, stacksize, price, is_undercut_price, deposit_cost, listing_status_id, user_id, is_tainted")
    Rails.cache.write("SalesListings.#{listing_id}.cached_saleslisting", data)
    end
    return data
  end

  def self.all_cached(user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.all_cached")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").joins("left join items on items.id = sales_listings.item_id").find(:all, :select => "sales_listings.id, item_id, stacksize, price, listing_status_id, is_undercut_price, is_tainted", :order => "position, items.description, sales_listings.updated_at desc", :conditions => ["listing_statuses.is_final = ? and user_id = ?", false, user_id])
    Rails.cache.write("SalesListings.#{user_id}.all_cached", data)
    end
    return data
  end

  def self.cached_prices(listing_id)
    data = Rails.cache.fetch("SalesListings.#{listing_id}.cached_prices")
    if data == nil then
    data = SalesListing.find(listing_id, :select => 'id, price')
    Rails.cache.write("SalesListings.#{listing_id}.cached_prices", data)
    end
    return data
  end

  def self.cached_profit(listing_id)
    data = Rails.cache.fetch("SalesListings.#{listing_id}.cached_profit")
    if data == nil then
      data = SalesListing.find(:first, :conditions => ["id = ?", listing_id], :select => "id, listing_status_id, profit")
    Rails.cache.write("SalesListings.#{listing_id}.cached_profit", data)
    end
    return data
  end

  def self.cached_sales_percentage_full_price(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_full_price")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.is_final = ? and user_id = ?", item_id, false, true, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_full_price", data)
    end
    return data
  end

  def self.cached_sales_percentage_undercut_price(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_undercut_price")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", item_id, true, "Sold", user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_undercut_price", data)
    end
    return data
  end

  def self.cached_total_auctions_overall(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_total_auctions_overall")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:id, :conditions => ["item_id = ? and listing_statuses.is_final = ? and user_id = ?", item_id, true, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_total_auctions_overall", data)
    end
    return data
  end

  def self.cached_average_selling_price(item_id, user_id, sold_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_average_selling_price")
    if data == nil then
      data = SalesListing.average(:price, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_id, item_id, false, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_average_selling_price", data)
    end
    return data
  end

  def self.cached_sold_auctions_overall(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sold_auctions_overall")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:id, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sold_auctions_overall", data)
    end
    return data
  end

  def self.cached_last_sold_auction(sold_status, item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_last_sold_auction")
    if data == nil then
      data = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status, item_id, false, user_id], :select => "id, listing_status_id, item_id, is_undercut_price, user_id, price, updated_at")
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_last_sold_auction", data)
    end
    return data
  end

  def self.cached_last_sold_date(sold_status, item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_last_sold_date")
    if data == nil then
      data = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and user_id = ?", sold_status, item_id, user_id], :select => "id, listing_status_id, item_id, user_id, updated_at")
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_last_sold_date", data)
    end
    return data
  end

  def self.cached_expired_listing(expired_status, item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_expired_listing")
    if data == nil then
      data = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired_status, item_id, false, user_id], :select => "id, listing_status_id, item_id, is_undercut_price, user_id, price, updated_at")
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_expired_listing", data)
    end
    return data
  end

  def self.cached_expired_count(expired_status, item_id, user_id, last_sold_date)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_expired_count")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and updated_at < ? and user_id = ?", expired_status, item_id, false, last_sold_date, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_expired_count", data)
    end
    return data
  end

  def self.cached_expired_count_overall(expired_status, item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_expired_count_overall")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired_status, item_id, false, user_id] )
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_expired_count_overall", data)
    end
    return data
  end

  def self.cached_listed_but_not_sold(expired_status, item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_listed_but_not_sold")
    if data == nil then
      data = SalesListing.find(:last, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired_status, item_id, false, user_id], :select => "id, price, listing_status_id, item_id, is_undercut_price, user_id")
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_listed_but_not_sold", data)
    end
    return data
  end

  def self.cached_lastSalesPrice_without_listed(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_lastSalesPrice_without_listed")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", item_id, false, "Sold", user_id]).last
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_lastSalesPrice_without_listed", data)
    end
    return data
  end

  def self.cached_lastSalesPrice_without_listed_including_undercut(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_lastSalesPrice_without_listed_including_undercut")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").find(:all, :conditions => ["item_id = ? and is_undercut_price = ? and listing_statuses.description = ? and user_id = ?", item_id, true, "Sold", user_id]).last
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_lastSalesPrice_without_listed_including_undercut", data)
    end
    return data
  end

  def self.cached_sold_not_undercut_count(item_id, user_id, sold_status)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sold_not_undercut_count")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status, item_id, false, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sold_not_undercut_count", data)
    end
    return data
  end

  def self.cached_expired_not_undercut_count(item_id, user_id, expired_status)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_expired_not_undercut_count")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired_status, item_id, false, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_expired_not_undercut_count", data)
    end
    return data
  end

  def self.cached_sold_and_undercut_count(item_id, user_id, sold_status)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sold_and_undercut_count")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", sold_status, item_id, true, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sold_and_undercut_count", data)
    end
    return data
  end

  def self.cached_expired_and_undercut_count(item_id, user_id, expired_status)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_expired_and_undercut_count")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["listing_status_id = ? and item_id = ? and is_undercut_price = ? and user_id = ?", expired_status, item_id, true, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_expired_and_undercut_count", data)
    end
    return data
  end

  def self.cached_sales_listing_per_status_count(item_id, user_id, last_sold)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sales_listing_per_status_count")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["item_id = ? and updated_at >= ? and is_undercut_price = ? and user_id = ?", item_id, last_sold, false, user_id], :group => 'listing_status_id')
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sales_listing_per_status_count", data)
    end
    return data
  end

  def self.cached_sales_listing_per_status_overall_count(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sales_listing_per_status_overall_count")
    if data == nil then
      data = SalesListing.count(:id, :conditions => ["item_id = ? and is_undercut_price = ? and user_id = ?", item_id, false, user_id], :group => 'listing_status_id')
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sales_listing_per_status_overall_count", data)
    end
    return data
  end

  def self.cached_maximum_deposit_cost_for_item(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_maximum_deposit_cost_for_item")
    if data == nil then
      data = SalesListing.maximum("deposit_cost", :conditions => ["item_id = ? and user_id = ?", item_id, user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_maximum_deposit_cost_for_item", data)
    end
    return data
  end

  def self.cached_sold_count_for_item(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sold_count_for_item")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:all, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sold_count_for_item", data)
    end
    return data
  end

  
  
  ## clear block
  def self.clear_saleslisting_block(item_id, user_id, listing_id)

    if user_id != nil then
    Rails.cache.clear("SalesListings.#{user_id}.all_cached")
    Rails.cache.clear("SalesListings.#{user_id}.ongoing_listing_count_cached_for_user")
    Rails.cache.clear("SalesListings.#{user_id}.active_auctions_cached_for_user")
    Rails.cache.clear("Items.#{user_id}.cached_sold_count_for_item")
    end

    if listing_id != nil then
    Rails.cache.clear("SalesListings.#{listing_id}.cached_saleslisting")
    Rails.cache.clear("SalesListings.#{listing_id}.cached_profit")
    Rails.cache.clear("SalesListings.#{listing_id}.cached_prices")
    end
    if user_id != nil && item_id != nil then
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sold_auctions_overall")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_average_selling_price")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_last_sold_auction")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_total_auctions_overall")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_undercut_price")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.sold_auctions_including_undercut_cached_for_user")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.sold_auctions_cached_for_user")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.sold_auctions_cached_for_user")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_full_price")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.average_profit_cached_for_user")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_last_sold_date")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_expired_listing")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_expired_count")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_expired_count_overall")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_listed_but_not_sold")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_lastSalesPrice_without_listed")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_lastSalesPrice_without_listed_including_undercut")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sold_not_undercut_count")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_expired_not_undercut_count")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sold_and_undercut_count")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_expired_and_undercut_count")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sales_listing_per_status_count")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sales_listing_per_status_overall_count")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_maximum_deposit_cost_for_item")
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sold_count_for_item")
    end
  end

end


# == Schema Information
#
# Table name: sales_listings
#
#  id                :integer         primary key
#  item_id           :integer
#  stacksize         :integer
#  price             :integer
#  deposit_cost      :integer
#  listing_status_id :integer
#  created_at        :timestamp
#  updated_at        :timestamp
#  is_undercut_price :boolean         default(FALSE)
#  relisted_status   :boolean         default(FALSE)
#  user_id           :integer
#  profit            :integer
#  is_tainted        :boolean         default(FALSE)
#

