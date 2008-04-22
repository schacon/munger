require File.dirname(__FILE__) + "/spec_helper"

describe Munger::Render do 
  include MungerSpecHelper
  
  before(:each) do 
    @data = Munger::Data.new(:data => test_data)
    @report = Munger::Report.new(:data => @data).process
  end

  it "should render html" do
    html = Munger::Render.to_html(@report)
    html.should have_tag('table')
  end
  
  it "should render text" do
    text = Munger::Render.to_text(@report)
    text.should_not have_tag('table')
    text.split("\n").should have_at_least(5).items
  end

  it "should render xls"

  it "should render csv"

  it "should render pdf"
  
end