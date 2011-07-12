require 'spec_helper'



describe ListingStatusesController do

  before(:each) do
    @attr = { :description => "sample status"}
  end

  describe "GET 'listing_statuses'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'listing_status' details" do

    it "should be successful" do
      valid_ListingStatus = ListingStatus.create!(@attr)
      get 'show', :id => valid_ListingStatus
      response.should be_success
    end
  end

  describe "POST 'listing_status' new record" do
    it "should change database count" do
      lambda do
        post :create, :listing_status => @attr
      end.should change(ListingStatus, :count)
    end
  end

  describe "POST 'listing_status' update record" do
    it "should change record data" do
      valid_ListingStatus = ListingStatus.create!(@attr)
      lambda do
        valid_ListingStatus.description = "sample ListingStatus 2!"
        post :update, :id => valid_ListingStatus
      end.should change(valid_ListingStatus, :description)
    end
  end

  describe "DELETE 'listing_status' delete record" do
    it "should change record data" do
      valid_ListingStatus = ListingStatus.create!(@attr)
      lambda do
        post :destroy, :id => valid_ListingStatus
      end.should change(ListingStatus, :count)
    end
  end

end
