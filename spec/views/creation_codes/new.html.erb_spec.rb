require 'spec_helper'

describe "creation_codes/new.html.erb" do
  before(:each) do
    assign(:creation_code, stub_model(CreationCode,
      :creation_code => "MyString",
      :used => false
    ).as_new_record)
  end

  it "renders new creation_code form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => creation_codes_path, :method => "post" do
      assert_select "input#creation_code_creation_code", :name => "creation_code[creation_code]"
      assert_select "input#creation_code_used", :name => "creation_code[used]"
    end
  end
end
