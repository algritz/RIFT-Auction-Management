class Source < ActiveRecord::Base
  attr_accessible :description, :crafting_allowed
  litteral_string =  /\w\D\z/i
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>32},  :format => { :with => litteral_string }, :uniqueness => true  
end


# == Schema Information
#
# Table name: sources
#
#  id          :integer         primary key
#  description :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp
#

