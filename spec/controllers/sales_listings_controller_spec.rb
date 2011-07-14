require 'spec_helper'

describe SalesListingsController do

  def mock_sales_listing(stubs={})
    @mock_sales_listing ||= mock_model(SalesListing, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all sales_listings as @sales_listings" do
      SalesListing.stub(:all) { [mock_sales_listing] }
      get :index
      assigns(:sales_listings).should eq([mock_sales_listing])
    end
  end

  describe "GET show" do
    it "assigns the requested sales_listing as @sales_listing" do
      SalesListing.stub(:find).with("37") { mock_sales_listing }
      get :show, :id => "37"
      assigns(:sales_listing).should be(mock_sales_listing)
    end
  end

  describe "GET new" do
    it "assigns a new sales_listing as @sales_listing" do
      SalesListing.stub(:new) { mock_sales_listing }
      get :new
      assigns(:sales_listing).should be(mock_sales_listing)
    end
  end

  describe "GET edit" do
    it "assigns the requested sales_listing as @sales_listing" do
      SalesListing.stub(:find).with("37") { mock_sales_listing }
      get :edit, :id => "37"
      assigns(:sales_listing).should be(mock_sales_listing)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created sales_listing as @sales_listing" do
        SalesListing.stub(:new).with({'these' => 'params'}) { mock_sales_listing(:save => true) }
        post :create, :sales_listing => {'these' => 'params'}
        assigns(:sales_listing).should be(mock_sales_listing)
      end

      it "redirects to the created sales_listing" do
        SalesListing.stub(:new) { mock_sales_listing(:save => true) }
        post :create, :sales_listing => {}
        response.should redirect_to(sales_listing_url(mock_sales_listing))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sales_listing as @sales_listing" do
        SalesListing.stub(:new).with({'these' => 'params'}) { mock_sales_listing(:save => false) }
        post :create, :sales_listing => {'these' => 'params'}
        assigns(:sales_listing).should be(mock_sales_listing)
      end

      it "re-renders the 'new' template" do
        SalesListing.stub(:new) { mock_sales_listing(:save => false) }
        post :create, :sales_listing => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested sales_listing" do
        SalesListing.should_receive(:find).with("37") { mock_sales_listing }
        mock_sales_listing.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :sales_listing => {'these' => 'params'}
      end

      it "assigns the requested sales_listing as @sales_listing" do
        SalesListing.stub(:find) { mock_sales_listing(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:sales_listing).should be(mock_sales_listing)
      end

      it "redirects to the sales_listing" do
        SalesListing.stub(:find) { mock_sales_listing(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(sales_listing_url(mock_sales_listing))
      end
    end

    describe "with invalid params" do
      it "assigns the sales_listing as @sales_listing" do
        SalesListing.stub(:find) { mock_sales_listing(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:sales_listing).should be(mock_sales_listing)
      end

      it "re-renders the 'edit' template" do
        SalesListing.stub(:find) { mock_sales_listing(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested sales_listing" do
      SalesListing.should_receive(:find).with("37") { mock_sales_listing }
      mock_sales_listing.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the sales_listings list" do
      SalesListing.stub(:find) { mock_sales_listing }
      delete :destroy, :id => "1"
      response.should redirect_to(sales_listings_url)
    end
  end

end
