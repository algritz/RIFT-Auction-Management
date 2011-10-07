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

  def self.cached_sold_auctions_overall(item_id, user_id)
    data = Rails.cache.fetch("SalesListings.#{user_id}.#{item_id}.cached_sold_auctions_overall")
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on Sales_listings.listing_status_id = listing_statuses.id").count(:id, :conditions => ["item_id = ? and listing_statuses.description = ? and user_id = ?", item_id, "Sold", user_id])
    Rails.cache.write("SalesListings.#{user_id}.#{item_id}.cached_sold_auctions_overall", data)
    end
    return data
  end

  def self.clear_cached_prices(listing_id)
    Rails.cache.clear("SalesListings.#{listing_id}.cached_prices")
  end

  def self.clear_cached_profit(listing_id)
    Rails.cache.clear("SalesListings.#{listing_id}.cached_profit")
  end

  def self.clear_all_cached(user_id)
    Rails.cache.clear("SalesListings.#{user_id}.all_cached")
    Rails.cache.clear("SalesListings.#{user_id}.ongoing_listing_count_cached_for_user")
    Rails.cache.clear("SalesListings.#{user_id}.active_auctions_cached_for_user")
  end

  def self.clear_average_profit_cached_for_user(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.average_profit_cached_for_user")
  end

  def self.clear_cached_sales_percentage_full_price(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_full_price")
  end

  def self.clear_sold_auctions_cached_for_user(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.sold_auctions_cached_for_user")
  end

  def self.clear_sold_auctions_cached_for_user(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.sold_auctions_cached_for_user")
  end

  def self.clear_sold_auctions_including_undercut_cached_for_user(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.sold_auctions_including_undercut_cached_for_user")
  end

  def self.clear_cached_sales_percentage_undercut_price(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sales_percentage_undercut_price")
  end

  def self.clear_cached_total_auctions_overall(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_total_auctions_overall")
  end
  
  def self.clear_cached_sold_auctions_overall(item_id, user_id)
    Rails.cache.clear("SalesListings.#{user_id}.#{item_id}.cached_sold_auctions_overall")
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
#  is_undercut_price :boolean
#  relisted_status   :boolean         default(FALSE)
#  user_id           :integer
#

