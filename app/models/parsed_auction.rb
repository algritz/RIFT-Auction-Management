class ParsedAuction < ActiveRecord::Base
  attr_accessible :sales_listing_id, :item_name, :user_id
  validates :sales_listing_id, :presence => true
  validates :item_name, :presence => true
  validates :user_id, :presence => true

end
