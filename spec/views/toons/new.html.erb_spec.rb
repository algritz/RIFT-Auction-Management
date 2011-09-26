require 'spec_helper'

describe "toons/new.html.erb" do
  before(:each) do
    assign(:toon, stub_model(Toon,
      :name => "MyString",
      :user_id => 1
    ).as_new_record)
  end

  it "renders new toon form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => toons_path, :method => "post" do
      assert_select "input#toon_name", :name => "toon[name]"
      assert_select "input#toon_user_id", :name => "toon[user_id]"
    end
  end
end
