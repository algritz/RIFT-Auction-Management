class CraftedItem < ActiveRecord::Base
  include ActiveModel::Validations

  attr_accessible :crafted_item_generated_id, :crafted_item_stacksize, :component_item_id, :component_item_quantity
  validates :crafted_item_generated_id, :presence => true
  validates :crafted_item_stacksize, :presence => true
  validates :component_item_id, :presence => true
  validates :component_item_quantity, :presence => true
  validates_numericality_of :crafted_item_stacksize, :component_item_quantity
  validates_uniqueness_of :component_item_id, :scope => :crafted_item_generated_id, :message => 'is already used for that pattern.'

  cattr_reader :per_page
  @@per_page = 20
  def self.search(search, page)
    paginate :per_page => 20, :page => page,
    :select => 'id, name, crafted_item_stacksize, component_item_quantity, required_skill, required_skill_point, crafted_item_generated_id, component_item_id',
    :order => 'required_skill, name',
    :conditions => ['name like ?', "%#{search}%"], :order => "name"
  end

  has_many :items

  ## makes sure an item is not component of itself
  validates_each :component_item_id do |model, attr, value|
    if value == model.crafted_item_generated_id
    model.errors.add(attr, "Item cannot be a self-composed.")
    end
  end

  def self.cached_crafted_item(item_id)
    data = Rails.cache.fetch("CraftedItem.#{item_id}.cached_crafted_item")
    if data == nil then
      data = CraftedItem.find(:first, :conditions => ["id = ?", item_id], :select => 'id, name, crafted_item_stacksize, component_item_quantity, required_skill, required_skill_point, crafted_item_generated_id, component_item_id')
    Rails.cache.write("CraftedItem.#{item_id}.cached_crafted_item", data)
    end
    return data
  end
  
  def self.cached_crafted_item_count(itemkey)
    data = Rails.cache.fetch("CraftedItem.#{itemkey}.cached_crafted_item_count")
    if data == nil then
      data = CraftedItem.count(:id, :conditions=> ["crafted_item_generated_id = ?", itemkey], :select => "id, crafted_item_generated_id")
    Rails.cache.write("CraftedItem.#{itemkey}.cached_crafted_item_count", data)
    end
    return data   
  end
  
  def self.cached_crafted_item_by_component_item_id(itemkey)
    data = Rails.cache.fetch("CraftedItem.#{itemkey}.cached_crafted_item_by_component_item_id")
    if data == nil then
      data = CraftedItem.find(:all, :conditions => ["crafted_item_generated_id = ?", itemkey], :select => "id, crafted_item_generated_id, component_item_id, component_item_quantity")
    Rails.cache.write("CraftedItem.#{itemkey}.cached_crafted_item_by_component_item_id", data)
    end
    return data    
  end
  
  def self.all_cached_crafted_item
    data = Rails.cache.fetch("CraftedItem.all_cached_crafted_item")
    if data == nil then
    data = CraftedItem.find(:all, :select => 'id, name, crafted_item_stacksize, component_item_quantity, required_skill, required_skill_point, crafted_item_generated_id, component_item_id', :order => "name")
    Rails.cache.write("CraftedItem.all_cached_crafted_item", data)
    end
    return data
  end

  def self.cached_source_description_for_crafted_item(item_id)
    data = Rails.cache.fetch("CraftedItem.#{item_id}.cached_source_description_for_crafted_item")
    if data == nil then
      data = CraftedItem.joins("left join items on items.itemkey = crafted_items.crafted_item_generated_id").find(:first, :conditions => ["items.id = ?", item_id], :select => "crafted_items.id, source_id, required_skill")
    Rails.cache.write("CraftedItem.#{item_id}.cached_source_description_for_crafted_item", data)
    end
    return data
  end

  def self.clear_cached_crafted_item(item_id)
    Rails.cache.clear("CraftedItem.#{item_id}.cached_crafted_item")
  end

  def self.clear_all_cached_crafted_item
    Rails.cache.clear("CraftedItem.all_cached_crafted_item")
  end

  def self.clear_cached_source_description_for_crafted_item(item_id)
    Rails.cache.clear("CraftedItem.#{item_id}.cached_source_description_for_crafted_item")
  end
  
  def self.clear_cached_crafted_item_by_component_item_id(itemkey)
    Rails.cache.clear("CraftedItem.#{itemkey}.cached_crafted_item_by_component_item_id")
  end
  
  def self.clear_cached_crafted_item_count(itemkey)
    Rails.cache.clear("CraftedItem.#{itemkey}.cached_crafted_item_count")
  end  
end

# == Schema Information
#
# Table name: crafted_items
#
#  id                        :integer         primary key
#  crafted_item_generated_id :integer
#  crafted_item_stacksize    :integer
#  component_item_id         :integer
#  component_item_quantity   :integer
#  created_at                :timestamp
#  updated_at                :timestamp
#

