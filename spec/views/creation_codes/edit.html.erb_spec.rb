require 'spec_helper'

describe "creation_codes/edit.html.erb" do
  before(:each) do
    @creation_code = assign(:creation_code, stub_model(CreationCode,
      :creation_code => "MyString",
      :used => false
    ))
  end

  it "renders the edit creation_code form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => creation_codes_path(@creation_code), :method => "post" do
      assert_select "input#creation_code_creation_code", :name => "creation_code[creation_code]"
      assert_select "input#creation_code_used", :name => "creation_code[used]"
    end
  end
end
