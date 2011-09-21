require "spec_helper"

describe CreationCodesController do
  describe "routing" do

    it "routes to #index" do
      get("/creation_codes").should route_to("creation_codes#index")
    end

    it "routes to #new" do
      get("/creation_codes/new").should route_to("creation_codes#new")
    end

    it "routes to #show" do
      get("/creation_codes/1").should route_to("creation_codes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/creation_codes/1/edit").should route_to("creation_codes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/creation_codes").should route_to("creation_codes#create")
    end

    it "routes to #update" do
      put("/creation_codes/1").should route_to("creation_codes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/creation_codes/1").should route_to("creation_codes#destroy", :id => "1")
    end

  end
end
