require 'spec_helper'

describe "wanted_items/show.html.erb" do
  before(:each) do
    @wanted_item = assign(:wanted_item, stub_model(WantedItem,
      :item_id => 1,
      :toon_id => 1,
      :is_public => false,
      :price_per => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
