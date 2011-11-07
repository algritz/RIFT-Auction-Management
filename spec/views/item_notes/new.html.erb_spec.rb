require 'spec_helper'


describe "item_notes/new.html.erb" do
  before(:each) do
    assign(:item_note, stub_model(ItemNote,

      :item_id => 1,

      :user_id => 1,

      :note => "MyText"

    ).as_new_record)
  end

  it "renders new item_note form" do
    render


    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => item_notes_path, :method => "post" do

      assert_select "input#item_note_item_id", :name => "item_note[item_id]"

      assert_select "input#item_note_user_id", :name => "item_note[user_id]"

      assert_select "textarea#item_note_note", :name => "item_note[note]"

    end

  end
end
