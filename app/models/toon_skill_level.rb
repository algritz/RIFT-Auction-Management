class ToonSkillLevel < ActiveRecord::Base
attr_accessible :toon_id, :source_id, :skill_level
validates_numericality_of :skill_level 
end
