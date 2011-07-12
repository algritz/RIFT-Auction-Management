require 'spec_helper'

describe CraftedItemsController do

  def mock_crafted_item(stubs={})
    @mock_crafted_item ||= mock_model(CraftedItem, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all crafted_items as @crafted_items" do
      CraftedItem.stub(:all) { [mock_crafted_item] }
      get :index
      assigns(:crafted_items).should eq([mock_crafted_item])
    end
  end

  describe "GET show" do
    it "assigns the requested crafted_item as @crafted_item" do
      CraftedItem.stub(:find).with("37") { mock_crafted_item }
      get :show, :id => "37"
      assigns(:crafted_item).should be(mock_crafted_item)
    end
  end

  describe "GET new" do
    it "assigns a new crafted_item as @crafted_item" do
      CraftedItem.stub(:new) { mock_crafted_item }
      get :new
      assigns(:crafted_item).should be(mock_crafted_item)
    end
  end

  describe "GET edit" do
    it "assigns the requested crafted_item as @crafted_item" do
      CraftedItem.stub(:find).with("37") { mock_crafted_item }
      get :edit, :id => "37"
      assigns(:crafted_item).should be(mock_crafted_item)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created crafted_item as @crafted_item" do
        CraftedItem.stub(:new).with({'these' => 'params'}) { mock_crafted_item(:save => true) }
        post :create, :crafted_item => {'these' => 'params'}
        assigns(:crafted_item).should be(mock_crafted_item)
      end

      it "redirects to the created crafted_item" do
        CraftedItem.stub(:new) { mock_crafted_item(:save => true) }
        post :create, :crafted_item => {}
        response.should redirect_to(crafted_item_url(mock_crafted_item))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved crafted_item as @crafted_item" do
        CraftedItem.stub(:new).with({'these' => 'params'}) { mock_crafted_item(:save => false) }
        post :create, :crafted_item => {'these' => 'params'}
        assigns(:crafted_item).should be(mock_crafted_item)
      end

      it "re-renders the 'new' template" do
        CraftedItem.stub(:new) { mock_crafted_item(:save => false) }
        post :create, :crafted_item => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested crafted_item" do
        CraftedItem.should_receive(:find).with("37") { mock_crafted_item }
        mock_crafted_item.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :crafted_item => {'these' => 'params'}
      end

      it "assigns the requested crafted_item as @crafted_item" do
        CraftedItem.stub(:find) { mock_crafted_item(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:crafted_item).should be(mock_crafted_item)
      end

      it "redirects to the crafted_item" do
        CraftedItem.stub(:find) { mock_crafted_item(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(crafted_item_url(mock_crafted_item))
      end
    end

    describe "with invalid params" do
      it "assigns the crafted_item as @crafted_item" do
        CraftedItem.stub(:find) { mock_crafted_item(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:crafted_item).should be(mock_crafted_item)
      end

      it "re-renders the 'edit' template" do
        CraftedItem.stub(:find) { mock_crafted_item(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested crafted_item" do
      CraftedItem.should_receive(:find).with("37") { mock_crafted_item }
      mock_crafted_item.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the crafted_items list" do
      CraftedItem.stub(:find) { mock_crafted_item }
      delete :destroy, :id => "1"
      response.should redirect_to(crafted_items_url)
    end
  end

end
