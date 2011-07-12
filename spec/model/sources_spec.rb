require 'spec_helper'



describe Source do

  before(:each) do
    @attr = { :description => "sample source"}
  end

  it "should not create a new source given invalid attributes" do
    invalid_source = Source.new
    invalid_source.should_not be_valid
  end

  it "should create a new source given valid attributes" do
    valid_source = Source.create!(@attr)
    valid_source.should be_valid
  end

  it "should not create a new source with a value too short" do
    invalid_source = Source.new(:description => "a")
    invalid_source.should_not be_valid
  end

  it "should not create a new source with a value too long" do
    invalid_source = Source.new(:description => ("a"*33))
    invalid_source.should_not be_valid
  end

  it "should not create a new source if it already exists" do
    valid_source = Source.create!(@attr)
    invalid_source = Source.new(@attr)
    invalid_source.should_not be_valid
  end

end