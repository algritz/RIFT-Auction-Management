require 'spec_helper'



describe SourcesController do

  before(:each) do
    @attr = { :description => "sample source"}
  end

  describe "GET 'sources'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'sources' details" do

    it "should be successful" do
      valid_source = Source.create!(@attr)
      get 'show', :id => valid_source
      response.should be_success
    end
  end

  describe "POST 'sources' new record" do
    it "should change database count" do
      lambda do
        post :create, :source => @attr
      end.should change(Source, :count)
    end
  end

  describe "POST 'sources' update record" do
    it "should change record data" do
      valid_source = Source.create!(@attr)
      lambda do
        valid_source.description = "sample source 2!"
        post :update, :id => valid_source
      end.should change(valid_source, :description)
    end
  end

    describe "DELETE 'sources' delete record" do
    it "should change record data" do
      valid_source = Source.create!(@attr)
      lambda do
        post :destroy, :id => valid_source
      end.should change(Source, :count)
    end
  end

end
