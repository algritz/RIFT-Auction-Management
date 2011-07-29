class ListingStatus < ActiveRecord::Base
  attr_accessible :description, :position
  litteral_string =  /\w\D\z/i
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>32},  :format => { :with => litteral_string }, :uniqueness => true  
  validates_numericality_of :position
  validates :position, :uniqueness => true
end

# == Schema Information
#
# Table name: listing_statuses
#
#  id          :integer         not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

