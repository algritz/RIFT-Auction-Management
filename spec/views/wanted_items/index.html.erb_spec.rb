require 'spec_helper'

describe "wanted_items/index.html.erb" do
  before(:each) do
    assign(:wanted_items, [
      stub_model(WantedItem,
        :item_id => 1,
        :toon_id => 1,
        :is_public => false,
        :price_per => 1
      ),
      stub_model(WantedItem,
        :item_id => 1,
        :toon_id => 1,
        :is_public => false,
        :price_per => 1
      )
    ])
  end

  it "renders a list of wanted_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
