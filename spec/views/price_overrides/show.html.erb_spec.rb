require 'spec_helper'

describe "price_overrides/show.html.erb" do
  before(:each) do
    @price_override = assign(:price_override, stub_model(PriceOverride,
      :item_id => 1,
      :user_id => 1,
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
    rendered.should match(/1/)
  end
end
