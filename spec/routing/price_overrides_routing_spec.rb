require "spec_helper"

describe PriceOverridesController do
  describe "routing" do

    it "routes to #index" do
      get("/price_overrides").should route_to("price_overrides#index")
    end

    it "routes to #new" do
      get("/price_overrides/new").should route_to("price_overrides#new")
    end

    it "routes to #show" do
      get("/price_overrides/1").should route_to("price_overrides#show", :id => "1")
    end

    it "routes to #edit" do
      get("/price_overrides/1/edit").should route_to("price_overrides#edit", :id => "1")
    end

    it "routes to #create" do
      post("/price_overrides").should route_to("price_overrides#create")
    end

    it "routes to #update" do
      put("/price_overrides/1").should route_to("price_overrides#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/price_overrides/1").should route_to("price_overrides#destroy", :id => "1")
    end

  end
end
