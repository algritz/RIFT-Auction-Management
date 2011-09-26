class WantedItem < ActiveRecord::Base
  attr_accessible :item_id, :toon_id, :is_public, :price_per
  validates_numericality_of :price_per, :allow_nil => true
end
