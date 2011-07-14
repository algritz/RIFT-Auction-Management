require 'spec_helper'

describe CompetitorsController do

  def mock_competitor(stubs={})
    @mock_competitor ||= mock_model(Competitor, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all competitors as @competitors" do
      Competitor.stub(:all) { [mock_competitor] }
      get :index
      assigns(:competitors).should eq([mock_competitor])
    end
  end

  describe "GET show" do
    it "assigns the requested competitor as @competitor" do
      Competitor.stub(:find).with("37") { mock_competitor }
      get :show, :id => "37"
      assigns(:competitor).should be(mock_competitor)
    end
  end

  describe "GET new" do
    it "assigns a new competitor as @competitor" do
      Competitor.stub(:new) { mock_competitor }
      get :new
      assigns(:competitor).should be(mock_competitor)
    end
  end

  describe "GET edit" do
    it "assigns the requested competitor as @competitor" do
      Competitor.stub(:find).with("37") { mock_competitor }
      get :edit, :id => "37"
      assigns(:competitor).should be(mock_competitor)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created competitor as @competitor" do
        Competitor.stub(:new).with({'these' => 'params'}) { mock_competitor(:save => true) }
        post :create, :competitor => {'these' => 'params'}
        assigns(:competitor).should be(mock_competitor)
      end

      it "redirects to the created competitor" do
        Competitor.stub(:new) { mock_competitor(:save => true) }
        post :create, :competitor => {}
        response.should redirect_to(competitor_url(mock_competitor))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved competitor as @competitor" do
        Competitor.stub(:new).with({'these' => 'params'}) { mock_competitor(:save => false) }
        post :create, :competitor => {'these' => 'params'}
        assigns(:competitor).should be(mock_competitor)
      end

      it "re-renders the 'new' template" do
        Competitor.stub(:new) { mock_competitor(:save => false) }
        post :create, :competitor => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested competitor" do
        Competitor.should_receive(:find).with("37") { mock_competitor }
        mock_competitor.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :competitor => {'these' => 'params'}
      end

      it "assigns the requested competitor as @competitor" do
        Competitor.stub(:find) { mock_competitor(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:competitor).should be(mock_competitor)
      end

      it "redirects to the competitor" do
        Competitor.stub(:find) { mock_competitor(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(competitor_url(mock_competitor))
      end
    end

    describe "with invalid params" do
      it "assigns the competitor as @competitor" do
        Competitor.stub(:find) { mock_competitor(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:competitor).should be(mock_competitor)
      end

      it "re-renders the 'edit' template" do
        Competitor.stub(:find) { mock_competitor(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested competitor" do
      Competitor.should_receive(:find).with("37") { mock_competitor }
      mock_competitor.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the competitors list" do
      Competitor.stub(:find) { mock_competitor }
      delete :destroy, :id => "1"
      response.should redirect_to(competitors_url)
    end
  end

end
