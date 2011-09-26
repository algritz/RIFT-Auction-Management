require "spec_helper"

describe WantedItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/wanted_items").should route_to("wanted_items#index")
    end

    it "routes to #new" do
      get("/wanted_items/new").should route_to("wanted_items#new")
    end

    it "routes to #show" do
      get("/wanted_items/1").should route_to("wanted_items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/wanted_items/1/edit").should route_to("wanted_items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/wanted_items").should route_to("wanted_items#create")
    end

    it "routes to #update" do
      put("/wanted_items/1").should route_to("wanted_items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/wanted_items/1").should route_to("wanted_items#destroy", :id => "1")
    end

  end
end
