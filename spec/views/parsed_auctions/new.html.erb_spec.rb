require 'spec_helper'

describe "parsed_auctions/new.html.erb" do
  before(:each) do
    assign(:parsed_auction, stub_model(ParsedAuction,
      :item_name => "MyString",
      :user_id => 1
    ).as_new_record)
  end

  it "renders new parsed_auction form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => parsed_auctions_path, :method => "post" do
      assert_select "input#parsed_auction_item_name", :name => "parsed_auction[item_name]"
      assert_select "input#parsed_auction_user_id", :name => "parsed_auction[user_id]"
    end
  end
end
