class SalesListing < ActiveRecord::Base
  attr_accessible :item_id, :stacksize, :price, :is_undercut_price, :deposit_cost, :listing_status_id
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
  
  has_one :item

end