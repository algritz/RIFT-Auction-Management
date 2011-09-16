class Item < ActiveRecord::Base
  attr_accessible :description, :vendor_selling_price, :vendor_buying_price, :source_id, :is_crafted, :to_list, :item_level, :note
  validates :description, :presence => true, :length => {:minimum=> 3, :maximum =>255}, :uniqueness => true
  validates_numericality_of :item_level, :allow_nil => true
  cattr_reader :per_page
  @@per_page = 20
  def self.search(search, page)
    paginate :per_page => 20, :page => page,
             :select => 'id, description, vendor_selling_price, vendor_buying_price, source_id',
             :order => 'source_id, description',
             :conditions => ['description like ?', "%#{search}%"], :order => "description"
  end
end


# == Schema Information
#
# Table name: items
#
#  id                   :integer         primary key
#  description          :string(255)
#  vendor_selling_price :integer
#  vendor_buying_price  :integer
#  source_id            :integer
#  created_at           :timestamp
#  updated_at           :timestamp
#  is_crafted           :boolean
#  to_list              :boolean
#  item_level           :integer
#

