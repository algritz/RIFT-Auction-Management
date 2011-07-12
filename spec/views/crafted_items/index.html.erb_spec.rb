require 'spec_helper'

describe "crafted_items/index.html.erb" do
  before(:each) do
    assign(:crafted_items, [
      stub_model(CraftedItem,
        :crafted_item_generated_id => 1,
        :crafted_item_stacksize => 1,
        :component_item_id => 1,
        :component_item_quantity => 1
      ),
      stub_model(CraftedItem,
        :crafted_item_generated_id => 1,
        :crafted_item_stacksize => 1,
        :component_item_id => 1,
        :component_item_quantity => 1
      )
    ])
  end

  it "renders a list of crafted_items" do
    render
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
  end
end
