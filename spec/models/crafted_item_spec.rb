require 'spec_helper'


describe CraftedItem do
  before(:each) do
    @attr = { :crafted_item_generated_id => 1,
      :crafted_item_stacksize => 1,
      :component_item_id => 2,
      :component_item_quantity => 1}
  end

  it "should not create a new Item given invalid attributes" do
    invalid_Item = CraftedItem.new
    invalid_Item.should_not be_valid
  end

  it "should create a new Item given valid attributes" do
    valid_Item = CraftedItem.create!(@attr)
    valid_Item.should be_valid
  end

  it "should not create a new Item if it already exists" do
    valid_Item = CraftedItem.create!(@attr)
    invalid_Item = CraftedItem.new(@attr)
    invalid_Item.should_not be_valid
  end
  
  it "should not create a new Item if it is self-contained" do
    invalid_Item = CraftedItem.new(@attr)
    invalid_Item.component_item_id = 1
    invalid_Item.should_not be_valid
  end
  
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
