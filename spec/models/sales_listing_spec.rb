require 'spec_helper'


describe SalesListing do

before(:each) do
    @attr = { :item_id => 1,
      :stacksize => 1,
      :price => 1,
      :undercut_price => 1,
      :deposit_cost => 1,
      :listing_status_id => 1 
      }
  end

it "should not create a new listing given invalid attributes" do
    invalid_listing = SalesListing.new
    invalid_listing.should_not be_valid
  end

it "should create a new listing given valid attributes" do
    valid_listing = SalesListing.create!(@attr)
    valid_listing.should be_valid
 end


end