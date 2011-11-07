
class ItemNote < ActiveRecord::Base
  validates :note, :presence => true
end

