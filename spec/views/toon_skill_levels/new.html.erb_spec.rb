require 'spec_helper'

describe "toon_skill_levels/new.html.erb" do
  before(:each) do
    assign(:toon_skill_level, stub_model(ToonSkillLevel,
      :toon_id => 1,
      :source_id => 1,
      :skill_level => 1
    ).as_new_record)
  end

  it "renders new toon_skill_level form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => toon_skill_levels_path, :method => "post" do
      assert_select "input#toon_skill_level_toon_id", :name => "toon_skill_level[toon_id]"
      assert_select "input#toon_skill_level_source_id", :name => "toon_skill_level[source_id]"
      assert_select "input#toon_skill_level_skill_level", :name => "toon_skill_level[skill_level]"
    end
  end
end
