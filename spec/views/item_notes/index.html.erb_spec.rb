require 'spec_helper'


describe "item_notes/index.html.erb" do
  before(:each) do
    assign(:item_notes, [

      stub_model(ItemNote,

        :item_id => 1,

        :user_id => 1,

        :note => "MyText"


      ),


      stub_model(ItemNote,

        :item_id => 1,

        :user_id => 1,

        :note => "MyText"


      )


    ])
  end

  it "renders a list of item_notes" do
    render


    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2



    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2



    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2


  end
end
