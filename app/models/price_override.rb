class PriceOverride < ActiveRecord::Base
  attr_accessible :item_id, :user_id, :price_per
  validates_numericality_of :item_id
  validates_numericality_of :user_id
  validates_numericality_of :price_per
  validates_uniqueness_of :item_id, :scope => [:user_id]
  
  cattr_reader :per_page
  @@per_page = 20
  def self.search(search, page)
    paginate :per_page => 20, :page => page,
           :joins => ("left join items on items.id = price_overrides.item_id"),
           :conditions => ['items.description like ?', "%#{search}%"], :order => "items.description"
  end
  
end
