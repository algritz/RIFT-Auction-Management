require 'spec_helper'

describe "price_overrides/index.html.erb" do
  before(:each) do
    assign(:price_overrides, [
      stub_model(PriceOverride,
        :item_id => 1,
        :user_id => 1,
        :price_per => 1
      ),
      stub_model(PriceOverride,
        :item_id => 1,
        :user_id => 1,
        :price_per => 1
      )
    ])
  end

  it "renders a list of price_overrides" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
