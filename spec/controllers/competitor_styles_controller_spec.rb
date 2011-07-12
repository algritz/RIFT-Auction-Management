require 'spec_helper'



describe CompetitorStylesController do

  before(:each) do
    @attr = { :description => "sample style"}
  end

  describe "GET 'competitor_styles'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'competitor_styles' details" do

    it "should be successful" do
      valid_CompetitorStyle = CompetitorStyle.create!(@attr)
      get 'show', :id => valid_CompetitorStyle
      response.should be_success
    end
  end

  describe "POST 'competitor_styles' new record" do
    it "should change database count" do
      lambda do
        post :create, :competitor_style => @attr
      end.should change(CompetitorStyle, :count)
    end
  end

  describe "POST 'competitor_styles' update record" do
    it "should change record data" do
      valid_CompetitorStyle = CompetitorStyle.create!(@attr)
      lambda do
        valid_CompetitorStyle.description = "sample CompetitorStyle 2!"
        put :update, :id => valid_CompetitorStyle
      end.should change(valid_CompetitorStyle, :description)
    end
  end

  describe "DELETE 'competitor_styles' delete record" do
    it "should change record data" do
      valid_CompetitorStyle = CompetitorStyle.create!(@attr)
      lambda do
        post :destroy, :id => valid_CompetitorStyle
      end.should change(CompetitorStyle, :count)
    end
  end

end
