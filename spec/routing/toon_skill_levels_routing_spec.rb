require "spec_helper"

describe ToonSkillLevelsController do
  describe "routing" do

    it "routes to #index" do
      get("/toon_skill_levels").should route_to("toon_skill_levels#index")
    end

    it "routes to #new" do
      get("/toon_skill_levels/new").should route_to("toon_skill_levels#new")
    end

    it "routes to #show" do
      get("/toon_skill_levels/1").should route_to("toon_skill_levels#show", :id => "1")
    end

    it "routes to #edit" do
      get("/toon_skill_levels/1/edit").should route_to("toon_skill_levels#edit", :id => "1")
    end

    it "routes to #create" do
      post("/toon_skill_levels").should route_to("toon_skill_levels#create")
    end

    it "routes to #update" do
      put("/toon_skill_levels/1").should route_to("toon_skill_levels#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/toon_skill_levels/1").should route_to("toon_skill_levels#destroy", :id => "1")
    end

  end
end
