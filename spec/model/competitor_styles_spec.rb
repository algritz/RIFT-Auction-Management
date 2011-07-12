require 'spec_helper'



describe CompetitorStyle do

  before(:each) do
    @attr = { :description => "sample style"}
  end

  it "should not create a new style given invalid attributes" do
    invalid_style = CompetitorStyle.new
    invalid_style.should_not be_valid
  end

  it "should create a new style given valid attributes" do
    valid_style = CompetitorStyle.create!(@attr)
    valid_style.should be_valid
  end

  it "should not create a new style with a value too short" do
    invalid_style = CompetitorStyle.new(:description => "a")
    invalid_style.should_not be_valid
  end

  it "should not create a new style with a value too long" do
    invalid_style = CompetitorStyle.new(:description => ("a"*33))
    invalid_style.should_not be_valid
  end

  it "should not create a new style if it already exists" do
    valid_style = CompetitorStyle.create!(@attr)
    invalid_style = CompetitorStyle.new(@attr)
    invalid_style.should_not be_valid
  end

end