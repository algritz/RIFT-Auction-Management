require 'spec_helper'

describe "ParsedAuctions" do
  describe "GET /parsed_auctions" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get parsed_auctions_path
      response.status.should be(200)
    end
  end
end
