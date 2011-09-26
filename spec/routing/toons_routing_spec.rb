require "spec_helper"

describe ToonsController do
  describe "routing" do

    it "routes to #index" do
      get("/toons").should route_to("toons#index")
    end

    it "routes to #new" do
      get("/toons/new").should route_to("toons#new")
    end

    it "routes to #show" do
      get("/toons/1").should route_to("toons#show", :id => "1")
    end

    it "routes to #edit" do
      get("/toons/1/edit").should route_to("toons#edit", :id => "1")
    end

    it "routes to #create" do
      post("/toons").should route_to("toons#create")
    end

    it "routes to #update" do
      put("/toons/1").should route_to("toons#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/toons/1").should route_to("toons#destroy", :id => "1")
    end

  end
end
