class Item < ActiveRecord::Base
  attr_accessible :description, :vendor_selling_price, :vendor_buying_price, :source_id, :is_crafted, :to_list
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>255}, :uniqueness => true
  
  cattr_reader :per_page
  @@per_page = 50

end

# == Schema Information
#
# Table name: items
#
#  id                   :integer         not null, primary key
#  description          :string(255)
#  vendor_selling_price :integer
#  vendor_buying_price  :integer
#  source_id            :integer
#  created_at           :datetime
#  updated_at           :datetime
#

