require "spec_helper"

describe SalesListingsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/sales_listings" }.should route_to(:controller => "sales_listings", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/sales_listings/new" }.should route_to(:controller => "sales_listings", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/sales_listings/1" }.should route_to(:controller => "sales_listings", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/sales_listings/1/edit" }.should route_to(:controller => "sales_listings", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/sales_listings" }.should route_to(:controller => "sales_listings", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/sales_listings/1" }.should route_to(:controller => "sales_listings", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/sales_listings/1" }.should route_to(:controller => "sales_listings", :action => "destroy", :id => "1")
    end

  end
end
