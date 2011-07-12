require 'spec_helper'



describe ItemsController do

  before(:each) do
    @attr = { :description => "sample Item"}
  end

  describe "GET 'Items'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'Items' details" do

    it "should be successful" do
      valid_Item = Item.create!(@attr)
      get 'show', :id => valid_Item
      response.should be_success
    end
  end

  describe "POST 'Items' new record" do
    it "should change database count" do
      lambda do
        post :create, :items => @attr
      end.should change(Item, :count)
    end
  end

  describe "POST 'Items' new invalid record" do
    it "should not change database count given invalid values" do
      lambda do
        post :create, :items => ""
      end.should_not change(Item, :count)
    end
  end


  describe "POST 'Items' update record" do
    it "should change record data" do
      valid_Item = Item.create!(@attr)
      lambda do
        valid_Item.description = "sample Item 2!"
        post :update, :id => valid_Item
      end.should change(valid_Item, :description)
    end
  end

    describe "DELETE 'Items' delete record" do
    it "should change record data" do
      valid_Item = Item.create!(@attr)
      lambda do
        post :destroy, :id => valid_Item
      end.should change(Item, :count)
    end
  end

end
