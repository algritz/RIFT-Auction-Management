require 'spec_helper'

describe "crafted_items/show.html.erb" do
  before(:each) do
    @crafted_item = assign(:crafted_item, stub_model(CraftedItem,
      :crafted_item_generated_id => 1,
      :crafted_item_stacksize => 1,
      :component_item_id => 1,
      :component_item_quantity => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain(1.to_s)
    rendered.should contain(1.to_s)
    rendered.should contain(1.to_s)
    rendered.should contain(1.to_s)
  end
end
