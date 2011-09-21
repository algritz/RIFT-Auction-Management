require 'spec_helper'

describe "creation_codes/index.html.erb" do
  before(:each) do
    assign(:creation_codes, [
      stub_model(CreationCode,
        :creation_code => "Creation Code",
        :used => false
      ),
      stub_model(CreationCode,
        :creation_code => "Creation Code",
        :used => false
      )
    ])
  end

  it "renders a list of creation_codes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Creation Code".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
