class ToonSkillLevel < ActiveRecord::Base
attr_accessible :toon_id, :source_id, :skill_level
validates_numericality_of :skill_level 
end

# == Schema Information
#
# Table name: toon_skill_levels
#
#  id          :integer         primary key
#  toon_id     :integer
#  source_id   :integer
#  skill_level :integer
#  created_at  :timestamp
#  updated_at  :timestamp
#

