class ParsedAuction < ActiveRecord::Base
  attr_accessible :item_name, :user_id
  validates :user_id, :presence => true
  validates :item_name, :presence => true
  
end
