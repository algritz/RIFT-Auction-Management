class ListingStatus < ActiveRecord::Base
  attr_accessible :description, :position, :is_final
  litteral_string =  /\w\D\z/i
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>32},  :format => { :with => litteral_string }, :uniqueness => true
  validates_numericality_of :position
  validates :position, :uniqueness => true
  def self.cached_listing_status(listing_status_id)
    data = Rails.cache.fetch("ListingStatus.#{listing_status_id}.cached_listing_status")
    if data == nil then
      data = ListingStatus.find(:first, :conditions => ["id = ?", listing_status_id], :select => "id, description, is_final")
    Rails.cache.write("ListingStatus.#{listing_status_id}.cached_listing_status", data)
    end
    return data
  end

  def self.cached_all_listing_status
    data = Rails.cache.fetch("ListingStatus.cached_all_listing_status")
    if data == nil then
    data = ListingStatus.find(:all, :select => "id, description, is_final")
    Rails.cache.write("ListingStatus.cached_all_listing_status", data)
    end
    return data
  end

  def self.cached_listing_status_from_description(listing_status_description)
    data = Rails.cache.fetch("ListingStatus.#{listing_status_description}.cached_listing_status_from_description")
    if data == nil then
      data = ListingStatus.find(:first, :conditions => ["description = ?", listing_status_description], :select => "id, description, is_final")
    Rails.cache.write("ListingStatus.#{listing_status_description}.cached_listing_status_from_description", data)
    end
    return data
  end

  def self.clear_cached(listing_status_id)
    Rails.cache.clear("ListingStatus.#{listing_status_id}.cached_listing_status")
    Rails.cache.clear("ListingStatus.cached_all_listing_status")
  end

  def self.clear_cached_from_description(listing_status_description)
    Rails.cache.clear("ListingStatus.#{listing_status_description}.cached_listing_status_from_description")
    Rails.cache.clear("ListingStatus.cached_all_listing_status")
  end

end

# == Schema Information
#
# Table name: listing_statuses
#
#  id          :integer         primary key
#  description :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp
#  position    :integer
#  is_final    :boolean         default(FALSE)
#

