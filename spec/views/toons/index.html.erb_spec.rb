require 'spec_helper'

describe "toons/index.html.erb" do
  before(:each) do
    assign(:toons, [
      stub_model(Toon,
        :name => "Name",
        :user_id => 1
      ),
      stub_model(Toon,
        :name => "Name",
        :user_id => 1
      )
    ])
  end

  it "renders a list of toons" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
