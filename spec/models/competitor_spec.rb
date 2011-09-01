require 'spec_helper'

describe Competitor do
    before(:each) do
    @attr = { :name => "sample competitor"}
  end

  it "should not create a new Competitor given invalid attributes" do
    invalid_style = Competitor.new
    invalid_style.should_not be_valid
  end

  it "should create a new Competitor given valid attributes" do
    valid_style = Competitor.create!(@attr)
    valid_style.should be_valid
  end

  it "should not create a new Competitor with a value too short" do
    invalid_style = Competitor.new(:name => "a")
    invalid_style.should_not be_valid
  end

  it "should not create a new Competitor with a value too long" do
    invalid_style = Competitor.new(:name => ("a"*33))
    invalid_style.should_not be_valid
  end

  it "should not create a new Competitor if it already exists for the same source" do
    valid_style = Competitor.create!(@attr)
    invalid_style = Competitor.new(@attr)
    invalid_style.should_not be_valid
  end
  
   it "should create a new Competitor if it already exists but not for the same source" do
    valid_style = Competitor.create!(@attr)
    invalid_style = Competitor.new(@attr)
    invalid_style.source_id = 5
    invalid_style.should be_valid
  end
  
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

