require 'spec_helper'

describe "price_overrides/new.html.erb" do
  before(:each) do
    assign(:price_override, stub_model(PriceOverride,
      :item_id => 1,
      :user_id => 1,
      :price_per => 1
    ).as_new_record)
  end

  it "renders new price_override form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => price_overrides_path, :method => "post" do
      assert_select "input#price_override_item_id", :name => "price_override[item_id]"
      assert_select "input#price_override_user_id", :name => "price_override[user_id]"
      assert_select "input#price_override_price_per", :name => "price_override[price_per]"
    end
  end
end
