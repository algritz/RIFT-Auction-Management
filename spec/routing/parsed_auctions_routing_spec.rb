require "spec_helper"

describe ParsedAuctionsController do
  describe "routing" do

    it "routes to #index" do
      get("/parsed_auctions").should route_to("parsed_auctions#index")
    end

    it "routes to #new" do
      get("/parsed_auctions/new").should route_to("parsed_auctions#new")
    end

    it "routes to #show" do
      get("/parsed_auctions/1").should route_to("parsed_auctions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/parsed_auctions/1/edit").should route_to("parsed_auctions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/parsed_auctions").should route_to("parsed_auctions#create")
    end

    it "routes to #update" do
      put("/parsed_auctions/1").should route_to("parsed_auctions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/parsed_auctions/1").should route_to("parsed_auctions#destroy", :id => "1")
    end

  end
end
