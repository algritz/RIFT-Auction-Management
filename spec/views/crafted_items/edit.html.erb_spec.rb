require 'spec_helper'

describe "crafted_items/edit.html.erb" do
  before(:each) do
    @crafted_item = assign(:crafted_item, stub_model(CraftedItem,
      :new_record? => false,
      :crafted_item_generated_id => 1,
      :crafted_item_stacksize => 1,
      :component_item_id => 1,
      :component_item_quantity => 1
    ))
  end

  it "renders the edit crafted_item form" do
    render

    rendered.should have_selector("form", :action => crafted_item_path(@crafted_item), :method => "post") do |form|
      form.should have_selector("input#crafted_item_crafted_item_generated_id", :name => "crafted_item[crafted_item_generated_id]")
      form.should have_selector("input#crafted_item_crafted_item_stacksize", :name => "crafted_item[crafted_item_stacksize]")
      form.should have_selector("input#crafted_item_component_item_id", :name => "crafted_item[component_item_id]")
      form.should have_selector("input#crafted_item_component_item_quantity", :name => "crafted_item[component_item_quantity]")
    end
  end
end
