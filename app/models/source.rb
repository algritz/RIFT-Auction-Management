class Source < ActiveRecord::Base
  attr_accessible :description, :crafting_allowed
  litteral_string =  /\w\D\z/i
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>32},  :format => { :with => litteral_string }, :uniqueness => true  
  
   def self.cached_source(source_id)
    data = Rails.cache.fetch("Source.#{source_id}.cached_source")
    if data == nil then
      data = Source.find(:first, :conditions => ["id = ?", source_id], :select => "id, description, crafting_allowed")
      Rails.cache.write("Source.#{source_id}.cached_source", data)
    end
    return data
  end
  
  def self.cached_all_sources
    data = Rails.cache.fetch("Source.cached_all_sources")
    if data == nil then
      data = Source.find(:all, :select => "id, description, crafting_allowed", :order => "description")
      Rails.cache.write("Source.cached_all_sources", data)
    end
    return data
  end
  
  def self.clear_cached_source(source_id)
    Rails.cache.clear("Source.#{source_id}.cached_source")
  end
  
  def self.clear_cached_all_sources
    Rails.cache.clear("Source.cached_all_sources")
  end
  
end



# == Schema Information
#
# Table name: sources
#
#  id               :integer         primary key
#  description      :string(255)
#  created_at       :timestamp
#  updated_at       :timestamp
#  crafting_allowed :boolean
#

