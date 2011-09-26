require 'spec_helper'

describe "ToonSkillLevels" do
  describe "GET /toon_skill_levels" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get toon_skill_levels_path
      response.status.should be(200)
    end
  end
end
