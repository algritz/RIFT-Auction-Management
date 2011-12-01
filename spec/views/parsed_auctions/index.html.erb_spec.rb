require 'spec_helper'

describe "parsed_auctions/index.html.erb" do
  before(:each) do
    assign(:parsed_auctions, [
      stub_model(ParsedAuction,
        :item_name => "Item Name",
        :user_id => 1
      ),
      stub_model(ParsedAuction,
        :item_name => "Item Name",
        :user_id => 1
      )
    ])
  end

  it "renders a list of parsed_auctions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Item Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
