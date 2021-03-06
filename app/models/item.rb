class Item < ActiveRecord::Base
  attr_accessible :description, :vendor_selling_price, :vendor_buying_price, :source_id, :is_crafted, :to_list, :item_level, :note
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>255}, :uniqueness => true
  validates_numericality_of :item_level, :allow_nil => true
  cattr_reader :per_page
  @@per_page = 10
  def self.search(search, page)
    paginate :per_page => 15, :page => page,
    :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id, itemkey, rarity',
    :order => 'source_id, description',
    :conditions => ['description like ?', "%#{search}%"], :order => "description"
  end

  def self.cached_item(item_id)
    data = Rails.cache.fetch("Item.#{item_id}.cached_item")
    if data == nil then
      data = Item.find(:first, :conditions => ["id = ?", item_id], :select => "id, description, vendor_selling_price, vendor_buying_price, source_id, item_level, is_crafted, to_list, note, rarity, item_level, itemkey")
    Rails.cache.write("Item.#{item_id}.cached_item", data)
    end
    return data
  end

  def self.cached_item_name(item_name)
    data = Rails.cache.fetch("Item.#{item_name}.cached_item_name")
    if data == nil then
      data = Item.find(:first, :conditions => ["description = ?", item_name], :select => "id, description")
    Rails.cache.write("Item.#{item_name}.cached_item_name", data)
    end
    return data
  end

  def self.cached_item_by_itemkey(itemkey)
    data = Rails.cache.fetch("Item.#{itemkey}.cached_item_by_itemkey")
    if data == nil then
      data = Item.find(:first, :conditions => ["itemkey = ?", itemkey], :select => "id, itemkey")
    Rails.cache.write("Item.#{itemkey}.cached_item_by_itemkey", data)
    end
    return data
  end

  def self.all_cached_item
    data = Rails.cache.fetch("Item.all_cached_item")
    if data == nil then
    data = Item.find(:all, :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id, itemkey, rarity', :order => 'description')
    Rails.cache.write("Item.all_cached_item", data)
    end
    return data
  end

  def self.all_cached_item_to_list
    data = Rails.cache.fetch("Item.all_cached_item_to_list")
    if data == nil then
      data = Item.find(:all, :select => 'id, description', :order => 'description', :conditions => ["to_list = ? and isaugmented = ? and soulboundtrigger <> ? and rarity <>  ?", true, false, "BindOnPickup", "Trash"])
    Rails.cache.write("Item.all_cached_item_to_list", data)
    end
    return data
  end

  def self.cached_item_from_key(item_key)
    data = Rails.cache.fetch("Item.#{item_key}.cached_item_from_key")
    if data == nil then
      data = Item.find(:first, :conditions => ["itemkey = ?", item_key], :select => "id, description, itemkey")
    Rails.cache.write("Item.#{item_key}.cached_item_from_key", data)
    end
    return data
  end

  def self.clear_cached(item_id)
    Rails.cache.clear("Item.#{item_id}.cached_item")
    Rails.cache.clear("ItemToCraft.#{item_id}.cached_item_source_description")
    self.clear_all_cached
  end

  def self.cached_items_without_listings(user_id, ongoing_item_ids_list)
    data = Rails.cache.fetch("Items.#{user_id}.cached_sold_count_for_item")
    if data == nil then
      data = Item.find(:all, :conditions => ["to_list = ? and is_crafted = ? and id not in (?)", true, true, ongoing_item_ids_list], :select => "id, description, source_id", :order => "source_id, description")
    Rails.cache.write("Items.#{user_id}.cached_items_without_listings", data)
    end
    return data
  end

  ## the reason why it is listed a second time is that I want to clear it from the cache for crafted item if its not needed
  def self.clear_cached_item_source_description(item_id)
    Rails.cache.clear("ItemToCraft.#{item_id}.cached_item_source_description")
  end

  def self.clear_all_cached
    Rails.cache.clear("Item.all_cached_item_to_list")
    Rails.cache.clear("Item.all_cached_item")
  end

  def self.clear_cached_item_by_itemkey(itemkey)
    Rails.cache.clear("Item.#{itemkey}.cached_item_by_itemkey")
  end

  def self.clear_cached_item_name(item_name)
    Rails.cache.fetch("Item.#{item_name}.cached_item_name")
  end

end

# == Schema Information
#
# Table name: items
#
#  id                   :integer         primary key
#  description          :string(255)
#  vendor_selling_price :integer
#  vendor_buying_price  :integer
#  source_id            :integer
#  created_at           :timestamp
#  updated_at           :timestamp
#  is_crafted           :boolean
#  to_list              :boolean
#  item_level           :integer
#  note                 :string(255)
#  itemkey              :string(255)
#  rarity               :string(255)
#  icon                 :string(255)
#  soulboundtrigger     :string(255)
#  riftgem              :string(255)
#  salvageskill         :string(255)
#  salvageskilllevel    :integer
#  runebreakskilllevel  :integer
#  isaugmented          :boolean
#

