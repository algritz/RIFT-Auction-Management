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

  def self.all_cached(user_id)
    data = Rails.cache.fetch("SalesListing.#{user_id}.all") { all }
    if data == nil then
      data = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").joins("left join items on items.id = sales_listings.item_id").find(:all,
      :conditions => ["listing_statuses.is_final = ? and user_id = ?", false, user_id])
      Rails.cache.write("SalesListing.#{user_id}.all", data)
    else
    #  Rails.cache.delete("SalesListing.#{user_id}.all")
    #   data = SalesListing.joins("left join listing_statuses on sales_listings.listing_status_id = listing_statuses.id").joins("left join items on items.id = sales_listings.item_id").find(:all,
    #  :conditions => ["listing_statuses.is_final = ? and user_id = ?", false, user_id])
    #  Rails.cache.write("SalesListing.#{user_id}.all", data)
    p "data was already existing"
    end
    return data
  end

  def self.sales_listing_cached(user_id)
    Rails.cache.fetch("SalesListing.#{user_id}.id") { id }
  end

  def self.clear_all_cached(user_id)
    Rails.cache.delete("SalesListing.#{user_id}.all")
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

