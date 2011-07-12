class CraftedItem < ActiveRecord::Base
  attr_accessible :crafted_item_generated_id, :crafted_item_stacksize, :component_item_id, :component_item_quantity
  validates :crafted_item_generated_id, :presence => true
  validates :crafted_item_stacksize, :presence => true
  validates :component_item_id, :presence => true
  validates :component_item_quantity, :presence => true
  validates_numericality_of :crafted_item_generated_id, :crafted_item_stacksize, :component_item_id, :component_item_quantity
  validates_uniqueness_of :component_item_id, :scope => :crafted_item_generated_id, :message => 'is already used for that pattern.'
  has_many :items
end

# == Schema Information
#
# Table name: crafted_items
#
#  id                        :integer         not null, primary key
#  crafted_item_generated_id :integer
#  crafted_item_stacksize    :integer
#  component_item_id         :integer
#  component_item_quantity   :integer
#  created_at                :datetime
#  updated_at                :datetime
#

