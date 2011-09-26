require 'spec_helper'

describe "toons/edit.html.erb" do
  before(:each) do
    @toon = assign(:toon, stub_model(Toon,
      :name => "MyString",
      :user_id => 1
    ))
  end

  it "renders the edit toon form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => toons_path(@toon), :method => "post" do
      assert_select "input#toon_name", :name => "toon[name]"
      assert_select "input#toon_user_id", :name => "toon[user_id]"
    end
  end
end
