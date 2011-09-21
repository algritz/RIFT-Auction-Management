require 'spec_helper'

describe "creation_codes/show.html.erb" do
  before(:each) do
    @creation_code = assign(:creation_code, stub_model(CreationCode,
      :creation_code => "Creation Code",
      :used => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Creation Code/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
