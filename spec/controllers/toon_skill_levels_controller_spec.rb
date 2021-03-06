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

describe ToonSkillLevelsController do

  # This should return the minimal set of attributes required to create a valid
  # ToonSkillLevel. As you add validations to ToonSkillLevel, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all toon_skill_levels as @toon_skill_levels" do
      toon_skill_level = ToonSkillLevel.create! valid_attributes
      get :index
      assigns(:toon_skill_levels).should eq([toon_skill_level])
    end
  end

  describe "GET show" do
    it "assigns the requested toon_skill_level as @toon_skill_level" do
      toon_skill_level = ToonSkillLevel.create! valid_attributes
      get :show, :id => toon_skill_level.id.to_s
      assigns(:toon_skill_level).should eq(toon_skill_level)
    end
  end

  describe "GET new" do
    it "assigns a new toon_skill_level as @toon_skill_level" do
      get :new
      assigns(:toon_skill_level).should be_a_new(ToonSkillLevel)
    end
  end

  describe "GET edit" do
    it "assigns the requested toon_skill_level as @toon_skill_level" do
      toon_skill_level = ToonSkillLevel.create! valid_attributes
      get :edit, :id => toon_skill_level.id.to_s
      assigns(:toon_skill_level).should eq(toon_skill_level)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ToonSkillLevel" do
        expect {
          post :create, :toon_skill_level => valid_attributes
        }.to change(ToonSkillLevel, :count).by(1)
      end

      it "assigns a newly created toon_skill_level as @toon_skill_level" do
        post :create, :toon_skill_level => valid_attributes
        assigns(:toon_skill_level).should be_a(ToonSkillLevel)
        assigns(:toon_skill_level).should be_persisted
      end

      it "redirects to the created toon_skill_level" do
        post :create, :toon_skill_level => valid_attributes
        response.should redirect_to(ToonSkillLevel.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved toon_skill_level as @toon_skill_level" do
        # Trigger the behavior that occurs when invalid params are submitted
        ToonSkillLevel.any_instance.stub(:save).and_return(false)
        post :create, :toon_skill_level => {}
        assigns(:toon_skill_level).should be_a_new(ToonSkillLevel)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ToonSkillLevel.any_instance.stub(:save).and_return(false)
        post :create, :toon_skill_level => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested toon_skill_level" do
        toon_skill_level = ToonSkillLevel.create! valid_attributes
        # Assuming there are no other toon_skill_levels in the database, this
        # specifies that the ToonSkillLevel created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ToonSkillLevel.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => toon_skill_level.id, :toon_skill_level => {'these' => 'params'}
      end

      it "assigns the requested toon_skill_level as @toon_skill_level" do
        toon_skill_level = ToonSkillLevel.create! valid_attributes
        put :update, :id => toon_skill_level.id, :toon_skill_level => valid_attributes
        assigns(:toon_skill_level).should eq(toon_skill_level)
      end

      it "redirects to the toon_skill_level" do
        toon_skill_level = ToonSkillLevel.create! valid_attributes
        put :update, :id => toon_skill_level.id, :toon_skill_level => valid_attributes
        response.should redirect_to(toon_skill_level)
      end
    end

    describe "with invalid params" do
      it "assigns the toon_skill_level as @toon_skill_level" do
        toon_skill_level = ToonSkillLevel.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ToonSkillLevel.any_instance.stub(:save).and_return(false)
        put :update, :id => toon_skill_level.id.to_s, :toon_skill_level => {}
        assigns(:toon_skill_level).should eq(toon_skill_level)
      end

      it "re-renders the 'edit' template" do
        toon_skill_level = ToonSkillLevel.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ToonSkillLevel.any_instance.stub(:save).and_return(false)
        put :update, :id => toon_skill_level.id.to_s, :toon_skill_level => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested toon_skill_level" do
      toon_skill_level = ToonSkillLevel.create! valid_attributes
      expect {
        delete :destroy, :id => toon_skill_level.id.to_s
      }.to change(ToonSkillLevel, :count).by(-1)
    end

    it "redirects to the toon_skill_levels list" do
      toon_skill_level = ToonSkillLevel.create! valid_attributes
      delete :destroy, :id => toon_skill_level.id.to_s
      response.should redirect_to(toon_skill_levels_url)
    end
  end

end
