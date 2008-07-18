require File.dirname(__FILE__) + "/spec_helper"

describe Munger::Render::CSV do 
  include MungerSpecHelper
  
  before(:each) do 
    @data = Munger::Data.new(:data => test_data)
    @report = Munger::Report.new(:data => @data)
  end

  it "should accept a Munger::Report object" do
    Munger::Render::Text.new(@report.process).should be_valid
  end
  
  it "should render a basic text table" do
    @render = Munger::Render::CSV.new(@report.process)
    count = @report.rows
    text = @render.render
    text.split("\n").should have_at_least(count).items
  end
end