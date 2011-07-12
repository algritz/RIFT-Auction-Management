require 'spec_helper'

describe Item do

  before(:each) do
    @attr = { :description => "sample Item"}
  end

  it "should not create a new Item given invalid attributes" do
    invalid_Item = Item.new
    invalid_Item.should_not be_valid
  end

  it "should create a new Item given valid attributes" do
    valid_Item = Item.create!(@attr)
    valid_Item.should be_valid
  end

  it "should not create a new Item with a value too short" do
    invalid_Item = Item.new(:description => "a")
    invalid_Item.should_not be_valid
  end

  it "should not create a new Item with a value too long" do
    invalid_Item = Item.new(:description => ("a"*256))
    invalid_Item.should_not be_valid
  end

  it "should not create a new Item if it already exists" do
    valid_Item = Item.create!(@attr)
    invalid_Item = Item.new(@attr)
    invalid_Item.should_not be_valid
  end

end