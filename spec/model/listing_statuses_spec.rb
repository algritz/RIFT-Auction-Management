require 'spec_helper'



describe ListingStatus do

  before(:each) do
    @attr = { :description => "sample status"}
  end

  it "should not create a new status given invalid attributes" do
    invalid_status = ListingStatus.new
    invalid_status.should_not be_valid
  end

  it "should create a new status given valid attributes" do
    valid_status = ListingStatus.create!(@attr)
    valid_status.should be_valid
  end

  it "should not create a new status with a value too short" do
    invalid_status = ListingStatus.new(:description => "a")
    invalid_status.should_not be_valid
  end

  it "should not create a new status with a value too long" do
    invalid_status = ListingStatus.new(:description => ("a"*33))
    invalid_status.should_not be_valid
  end

    it "should not create a new status if it already exists" do
    valid_status = ListingStatus.create!(@attr)
    invalid_status = ListingStatus.new(@attr)
    invalid_status.should_not be_valid
  end

end