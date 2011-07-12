class Item < ActiveRecord::Base
  attr_accessible :description
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>255}, :uniqueness => true
end
