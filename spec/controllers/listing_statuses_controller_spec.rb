require 'spec_helper'

describe ListingStatusesController do

  describe "GET 'listing_statuses'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
 
end
