require File.dirname(__FILE__) + "/spec_helper"

describe Munger::Render::Html do 
  include MungerSpecHelper
  
  before(:each) do 
    @data = Munger::Data.new(:data => test_data)
    @report = Munger::Report.new(:data => @data)
  end

  it "should accept a Munger::Report object" do
    Munger::Render::Html.new(@report.process).should be_valid
  end

  it "should render a basic html table" do
    @render = Munger::Render::Html.new(@report.process)
    count = @report.rows
    
    html = @render.render
    html.should have_tag('table')
    html.should have_tag('tr', :count => count + 1) # rows plus header
  end
  
  it "should render columns in the right order" do
    @report = @report.columns([:age, :name]).process
    html = Munger::Render::Html.new(@report).render
    html.should have_tag('th', :count => 2) # rows plus header
    html.should match(/age(.*?)name/)
  end
  
  it "should render groups" do
    @report = @report.subgroup(:age).aggregate(:sum => :score).process
    html = Munger::Render::Html.new(@report).render
    html.should match(/151/) # only in the aggregate group
  end
  
  it "should render cell styles" do
    @report.process.style_rows('over_thirty') { |row| row.age > 29 }
    
    html = Munger::Render::Html.new(@report).render
    html.should have_tag('tr.over_thirty')
  end

  it "should render row styles" do
    @report.process.style_cells('highlight', :only => :age) { |c, r| c == 32 }
    html = Munger::Render::Html.new(@report).render
    html.should have_tag('td.highlight')
  end


end