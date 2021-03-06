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

describe WantedItemsController do

  # This should return the minimal set of attributes required to create a valid
  # WantedItem. As you add validations to WantedItem, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all wanted_items as @wanted_items" do
      wanted_item = WantedItem.create! valid_attributes
      get :index
      assigns(:wanted_items).should eq([wanted_item])
    end
  end

  describe "GET show" do
    it "assigns the requested wanted_item as @wanted_item" do
      wanted_item = WantedItem.create! valid_attributes
      get :show, :id => wanted_item.id.to_s
      assigns(:wanted_item).should eq(wanted_item)
    end
  end

  describe "GET new" do
    it "assigns a new wanted_item as @wanted_item" do
      get :new
      assigns(:wanted_item).should be_a_new(WantedItem)
    end
  end

  describe "GET edit" do
    it "assigns the requested wanted_item as @wanted_item" do
      wanted_item = WantedItem.create! valid_attributes
      get :edit, :id => wanted_item.id.to_s
      assigns(:wanted_item).should eq(wanted_item)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new WantedItem" do
        expect {
          post :create, :wanted_item => valid_attributes
        }.to change(WantedItem, :count).by(1)
      end

      it "assigns a newly created wanted_item as @wanted_item" do
        post :create, :wanted_item => valid_attributes
        assigns(:wanted_item).should be_a(WantedItem)
        assigns(:wanted_item).should be_persisted
      end

      it "redirects to the created wanted_item" do
        post :create, :wanted_item => valid_attributes
        response.should redirect_to(WantedItem.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wanted_item as @wanted_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        WantedItem.any_instance.stub(:save).and_return(false)
        post :create, :wanted_item => {}
        assigns(:wanted_item).should be_a_new(WantedItem)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        WantedItem.any_instance.stub(:save).and_return(false)
        post :create, :wanted_item => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested wanted_item" do
        wanted_item = WantedItem.create! valid_attributes
        # Assuming there are no other wanted_items in the database, this
        # specifies that the WantedItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        WantedItem.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => wanted_item.id, :wanted_item => {'these' => 'params'}
      end

      it "assigns the requested wanted_item as @wanted_item" do
        wanted_item = WantedItem.create! valid_attributes
        put :update, :id => wanted_item.id, :wanted_item => valid_attributes
        assigns(:wanted_item).should eq(wanted_item)
      end

      it "redirects to the wanted_item" do
        wanted_item = WantedItem.create! valid_attributes
        put :update, :id => wanted_item.id, :wanted_item => valid_attributes
        response.should redirect_to(wanted_item)
      end
    end

    describe "with invalid params" do
      it "assigns the wanted_item as @wanted_item" do
        wanted_item = WantedItem.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        WantedItem.any_instance.stub(:save).and_return(false)
        put :update, :id => wanted_item.id.to_s, :wanted_item => {}
        assigns(:wanted_item).should eq(wanted_item)
      end

      it "re-renders the 'edit' template" do
        wanted_item = WantedItem.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        WantedItem.any_instance.stub(:save).and_return(false)
        put :update, :id => wanted_item.id.to_s, :wanted_item => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested wanted_item" do
      wanted_item = WantedItem.create! valid_attributes
      expect {
        delete :destroy, :id => wanted_item.id.to_s
      }.to change(WantedItem, :count).by(-1)
    end

    it "redirects to the wanted_items list" do
      wanted_item = WantedItem.create! valid_attributes
      delete :destroy, :id => wanted_item.id.to_s
      response.should redirect_to(wanted_items_url)
    end
  end

end
