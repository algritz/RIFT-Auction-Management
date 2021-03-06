require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ParsedAuctionsController do

  # This should return the minimal set of attributes required to create a valid
  # ParsedAuction. As you add validations to ParsedAuction, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all parsed_auctions as @parsed_auctions" do
      parsed_auction = ParsedAuction.create! valid_attributes
      get :index
      assigns(:parsed_auctions).should eq([parsed_auction])
    end
  end

  describe "GET show" do
    it "assigns the requested parsed_auction as @parsed_auction" do
      parsed_auction = ParsedAuction.create! valid_attributes
      get :show, :id => parsed_auction.id
      assigns(:parsed_auction).should eq(parsed_auction)
    end
  end

  describe "GET new" do
    it "assigns a new parsed_auction as @parsed_auction" do
      get :new
      assigns(:parsed_auction).should be_a_new(ParsedAuction)
    end
  end

  describe "GET edit" do
    it "assigns the requested parsed_auction as @parsed_auction" do
      parsed_auction = ParsedAuction.create! valid_attributes
      get :edit, :id => parsed_auction.id
      assigns(:parsed_auction).should eq(parsed_auction)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ParsedAuction" do
        expect {
          post :create, :parsed_auction => valid_attributes
        }.to change(ParsedAuction, :count).by(1)
      end

      it "assigns a newly created parsed_auction as @parsed_auction" do
        post :create, :parsed_auction => valid_attributes
        assigns(:parsed_auction).should be_a(ParsedAuction)
        assigns(:parsed_auction).should be_persisted
      end

      it "redirects to the created parsed_auction" do
        post :create, :parsed_auction => valid_attributes
        response.should redirect_to(ParsedAuction.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved parsed_auction as @parsed_auction" do
        # Trigger the behavior that occurs when invalid params are submitted
        ParsedAuction.any_instance.stub(:save).and_return(false)
        post :create, :parsed_auction => {}
        assigns(:parsed_auction).should be_a_new(ParsedAuction)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ParsedAuction.any_instance.stub(:save).and_return(false)
        post :create, :parsed_auction => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested parsed_auction" do
        parsed_auction = ParsedAuction.create! valid_attributes
        # Assuming there are no other parsed_auctions in the database, this
        # specifies that the ParsedAuction created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ParsedAuction.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => parsed_auction.id, :parsed_auction => {'these' => 'params'}
      end

      it "assigns the requested parsed_auction as @parsed_auction" do
        parsed_auction = ParsedAuction.create! valid_attributes
        put :update, :id => parsed_auction.id, :parsed_auction => valid_attributes
        assigns(:parsed_auction).should eq(parsed_auction)
      end

      it "redirects to the parsed_auction" do
        parsed_auction = ParsedAuction.create! valid_attributes
        put :update, :id => parsed_auction.id, :parsed_auction => valid_attributes
        response.should redirect_to(parsed_auction)
      end
    end

    describe "with invalid params" do
      it "assigns the parsed_auction as @parsed_auction" do
        parsed_auction = ParsedAuction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ParsedAuction.any_instance.stub(:save).and_return(false)
        put :update, :id => parsed_auction.id, :parsed_auction => {}
        assigns(:parsed_auction).should eq(parsed_auction)
      end

      it "re-renders the 'edit' template" do
        parsed_auction = ParsedAuction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ParsedAuction.any_instance.stub(:save).and_return(false)
        put :update, :id => parsed_auction.id, :parsed_auction => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested parsed_auction" do
      parsed_auction = ParsedAuction.create! valid_attributes
      expect {
        delete :destroy, :id => parsed_auction.id
      }.to change(ParsedAuction, :count).by(-1)
    end

    it "redirects to the parsed_auctions list" do
      parsed_auction = ParsedAuction.create! valid_attributes
      delete :destroy, :id => parsed_auction.id
      response.should redirect_to(parsed_auctions_url)
    end
  end

end
