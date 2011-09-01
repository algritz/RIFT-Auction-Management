class Competitor < ActiveRecord::Base
  litteral_string =  /\w/i
  validates :name, :presence => true, :length => {:minimum=> 3, :maximum =>32},  :format => { :with => litteral_string }
  validates_uniqueness_of :name, :scope => :source_id, :message => ' has already been defined for that market'
  has_many :competitor_styles

  cattr_reader :per_page
  @@per_page = 50
end

# == Schema Information
#
# Table name: competitors
#
#  id                  :integer         primary key
#  name                :string(255)
#  competitor_style_id :integer
#  source_id           :integer
#  created_at          :timestamp
#  updated_at          :timestamp
#  user_id             :integer
#

