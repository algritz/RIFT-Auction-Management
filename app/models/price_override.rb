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

  def self.cached_price_override_for_item_for_user(user_id, item_id)
    data = Rails.cache.fetch("PriceOverride.#{user_id}.#{item_id}.cached_price_override_for_item_for_user")
    if data == nil then
      data = PriceOverride.find(:first, :conditions => ["user_id = ? and item_id = ?", user_id, item_id], :select => "id, user_id, item_id, price_per")
    Rails.cache.write("PriceOverride.#{user_id}.#{item_id}.cached_price_override_for_item_for_user", data)
    end
    return data
  end

  def self.clear_cached_price_override_for_item_for_user(user_id, item_id)
    Rails.cache.clear("PriceOverride.#{user_id}.#{item_id}.cached_price_override_for_item_for_user")
  end

end
