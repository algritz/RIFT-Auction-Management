class WantedItem < ActiveRecord::Base
  attr_accessible :item_id, :toon_id, :is_public, :price_per
  validates_numericality_of :price_per, :allow_nil => true
end

# == Schema Information
#
# Table name: wanted_items
#
#  id         :integer         primary key
#  item_id    :integer
#  toon_id    :integer
#  is_public  :boolean
#  price_per  :integer
#  created_at :timestamp
#  updated_at :timestamp
#

