require 'spec_helper'


describe "item_notes/show.html.erb" do
  before(:each) do
    @item_note = assign(:item_note, stub_model(ItemNote,

      :item_id => 1,

      :user_id => 1,

      :note => "MyText"


    ))

  end

  it "renders attributes in <p>" do
    render


    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)



    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)



    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)


  end
end
