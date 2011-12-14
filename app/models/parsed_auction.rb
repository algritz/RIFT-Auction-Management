class ParsedAuction < ActiveRecord::Base
  attr_accessible :sales_listing_id, :item_name, :user_id, :action_name, :deposit
  validates :sales_listing_id, :presence => true
  validates :item_name, :presence => true
  validates :user_id, :presence => true
  validates :action_name, :presence => true
  
   
end
