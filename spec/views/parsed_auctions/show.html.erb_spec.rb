require 'spec_helper'

describe "parsed_auctions/show.html.erb" do
  before(:each) do
    @parsed_auction = assign(:parsed_auction, stub_model(ParsedAuction,
      :item_name => "Item Name",
      :user_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Item Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
