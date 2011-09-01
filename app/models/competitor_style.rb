class CompetitorStyle < ActiveRecord::Base
  attr_accessible :description
  litteral_string =  /\w\D\z/i
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>32},  :format => { :with => litteral_string }, :uniqueness => true
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

