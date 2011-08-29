class SalesListing < ActiveRecord::Base
  attr_accessible :item_id, :stacksize, :price, :is_undercut_price, :deposit_cost, :listing_status_id, :user_id
  validates :item_id, :presence => true
  validates_numericality_of :item_id
  validates :stacksize, :presence => true
  validates_numericality_of :stacksize
  validates :deposit_cost, :presence => true
  validates_numericality_of :deposit_cost
  validates :listing_status_id, :presence => true
  validates_numericality_of :listing_status_id
  validates :price, :presence => true
  validates_numericality_of :price

  cattr_reader :per_page
  @@per_page = 20
  def self.search(search, page)
    paginate :per_page => 20, :page => page,
           :joins => ("left join items on items.id = sales_listings.item_id"),
           :conditions => ['items.description like ?', "%#{search}%"], :order => "items.description, sales_listings.id desc"
  end

end