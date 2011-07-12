require "spec_helper"

describe CraftedItemsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/crafted_items" }.should route_to(:controller => "crafted_items", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/crafted_items/new" }.should route_to(:controller => "crafted_items", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/crafted_items/1" }.should route_to(:controller => "crafted_items", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/crafted_items/1/edit" }.should route_to(:controller => "crafted_items", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/crafted_items" }.should route_to(:controller => "crafted_items", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/crafted_items/1" }.should route_to(:controller => "crafted_items", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/crafted_items/1" }.should route_to(:controller => "crafted_items", :action => "destroy", :id => "1")
    end

  end
end
