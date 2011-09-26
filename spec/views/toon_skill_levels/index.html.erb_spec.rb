require 'spec_helper'

describe "toon_skill_levels/index.html.erb" do
  before(:each) do
    assign(:toon_skill_levels, [
      stub_model(ToonSkillLevel,
        :toon_id => 1,
        :source_id => 1,
        :skill_level => 1
      ),
      stub_model(ToonSkillLevel,
        :toon_id => 1,
        :source_id => 1,
        :skill_level => 1
      )
    ])
  end

  it "renders a list of toon_skill_levels" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
