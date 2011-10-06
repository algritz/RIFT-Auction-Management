class CompetitorStyle < ActiveRecord::Base
  attr_accessible :description
  litteral_string =  /\w\D\z/i
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>32},  :format => { :with => litteral_string }, :uniqueness => true
  
  def self.cached_competitor_style(style_id)
    data = Rails.cache.fetch("CompetitorStyle.#{style_id}.cached_competitor_style")
    if data == nil then
      data = CompetitorStyle.find(:first, :conditions => ["id = ?", style_id], :select => "id, description")
    Rails.cache.write("CompetitorStyle.#{style_id}.cached_competitor_style", data)
    end
    return data
  end
  
   def self.cached_all_competitor_style
    data = Rails.cache.fetch("CompetitorStyle.cached_all_competitor_style")
    if data == nil then
      data = CompetitorStyle.find(:all, :select => "id, description")
      Rails.cache.write("CompetitorStyle.cached_all_competitor_style", data)
    end
    return data
  end
  
  def self.clear_cached_all_competitor_style
    Rails.cache.clear("CompetitorStyle.cached_all_competitor_style")
  end
  
  def self.clear_cached_competitor_style(style_id)
    Rails.cache.clear("CompetitorStyle.#{style_id}.cached_competitor_style")
  end

end

# == Schema Information
#
# Table name: competitor_styles
#
#  id          :integer         primary key
#  description :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp
#

