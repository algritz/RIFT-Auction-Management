class Toon < ActiveRecord::Base
  attr_accessible :name, :toon_id, :user_id
  validates :name, :presence => true, :length => 1..32
  
  
  def self.cached_toon(toon_id)
    data = Rails.cache.fetch("Toon.#{toon_id}.cached_toon")
    if data == nil then
      data = Toon.find(:first, :conditions => ["id = ?", toon_id], :select =>["id, name, user_id"])
    Rails.cache.write("Toon.#{toon_id}.cached_toon", data)
    end
    return data
  end
  
   def self.all_cached_toon_for_user(user_id)
    data = Rails.cache.fetch("Toon.#{user_id}.all_cached_toon_for_user")
    if data == nil then
      data = Toon.find(:all, :conditions => ["user_id = ?", user_id], :select => "id, name, user_id")
      Rails.cache.write("Toon.#{user_id}.all_cached_toon_for_user", data)
    end
    return data
  end
  
  
  def self.clear_cached_toon(toon_id)
    Rails.cache.clear("Toon.#{toon_id}.cached_toon")
  end
  
  def self.clear_all_cached_toon_for_user(user_id)
     Rails.cache.clear("Toon.#{user_id}.all_cached_toon_for_user")
  end
  
end

# == Schema Information
#
# Table name: toons
#
#  id         :integer         primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :timestamp
#  updated_at :timestamp
#

