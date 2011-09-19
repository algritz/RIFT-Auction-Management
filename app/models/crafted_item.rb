class CraftedItem < ActiveRecord::Base
  include ActiveModel::Validations

  attr_accessible :crafted_item_generated_id, :crafted_item_stacksize, :component_item_id, :component_item_quantity
  validates :crafted_item_generated_id, :presence => true
  validates :crafted_item_stacksize, :presence => true
  validates :component_item_id, :presence => true
  validates :component_item_quantity, :presence => true
  validates_numericality_of :crafted_item_stacksize, :component_item_quantity
  validates_uniqueness_of :component_item_id, :scope => :crafted_item_generated_id, :message => 'is already used for that pattern.'

  cattr_reader :per_page
  @@per_page = 20

  has_many :items

  validates_each :component_item_id do |model, attr, value|
    if value == model.crafted_item_generated_id
      model.errors.add(attr, "Item cannot be a self-composed.")
    end
  end

end


# == Schema Information
#
# Table name: crafted_items
#
#  id                        :integer         primary key
#  crafted_item_generated_id :integer
#  crafted_item_stacksize    :integer
#  component_item_id         :integer
#  component_item_quantity   :integer
#  created_at                :timestamp
#  updated_at                :timestamp
#

