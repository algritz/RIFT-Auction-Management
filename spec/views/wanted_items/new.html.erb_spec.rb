require 'spec_helper'

describe "wanted_items/new.html.erb" do
  before(:each) do
    assign(:wanted_item, stub_model(WantedItem,
      :item_id => 1,
      :toon_id => 1,
      :is_public => false,
      :price_per => 1
    ).as_new_record)
  end

  it "renders new wanted_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => wanted_items_path, :method => "post" do
      assert_select "input#wanted_item_item_id", :name => "wanted_item[item_id]"
      assert_select "input#wanted_item_toon_id", :name => "wanted_item[toon_id]"
      assert_select "input#wanted_item_is_public", :name => "wanted_item[is_public]"
      assert_select "input#wanted_item_price_per", :name => "wanted_item[price_per]"
    end
  end
end
