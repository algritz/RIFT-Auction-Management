require "spec_helper"

describe ItemNotesController do
  describe "routing" do


    it "routes to #index" do
      get("/item_notes").should route_to("item_notes#index")
    end


    it "routes to #new" do
      get("/item_notes/new").should route_to("item_notes#new")
    end

    it "routes to #show" do
      get("/item_notes/1").should route_to("item_notes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/item_notes/1/edit").should route_to("item_notes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/item_notes").should route_to("item_notes#create")
    end

    it "routes to #update" do
      put("/item_notes/1").should route_to("item_notes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/item_notes/1").should route_to("item_notes#destroy", :id => "1")
    end

  end
end
