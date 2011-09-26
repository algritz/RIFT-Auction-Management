class Toon < ActiveRecord::Base
  attr_accessible :name, :toon_id, :user_id
  validates :name, :presence => true, :length => 1..32
end
