require File.dirname(__FILE__) + "/spec_helper"

describe Munger::Report do 
  include MungerSpecHelper
  
  before(:each) do 
    @data = Munger::Data.new(:data => test_data)
    @report = Munger::Report.new(:data => @data)
  end

  it "should accept a Munger::Data object" do
    Munger::Report.new(:data => @data).should be_valid
  end
  
  it "should accept a array of hashes" do
    Munger::Report.new(:data => test_data).should be_valid
    Munger::Report.new(:data => invalid_test_data).should_not be_valid
  end

  it "should be able to sort fields by array" do
    @report.sort = 'name'
    data = @report.process.process_data
    data.map { |a| a[:data].name }[0, 4].join(',').should eql('Alice,Alice,Alice,Chaz')
    
    @report.sort = ['name', 'age']
    data = @report.process.process_data
    data.map { |a| a[:data].age }[0, 4].join(',').should eql('33,33,34,28')
    
    @report.sort = [['name', :asc], ['age', :desc]]
    data = @report.process.process_data
    data.map { |a| a[:data].age }[0, 4].join(',').should eql('34,33,33,28')
  end

  it "should be able to custom sort fields" do
    @report.sort = [['name', Proc.new {|a, b| a[2] <=> b[2]} ]]
    data = @report.process.process_data
    data.map { |a| a[:data].name }[0, 4].join(',').should eql('Chaz,Rich,Alice,Alice')
  end

  it "should be able to order columns" do
    @report.columns([:name, :age, :score])
    @report.columns.should eql([:name, :age, :score])
  end
  
  it "should default to all columns" do
    @report.columns.map { |c| c.to_s }.sort.join(',').should eql('age,day,name,score')
  end

  it "should be able to subgroup data" do
    @report.sort('name').subgroup('name').process
    @report.get_subgroup_rows.should have(6).items
  end

  it "should be able to subgroup in multiple dimensions"

  it "should be able to aggregate columns into subgroup rows" do
    @report.sort('name').subgroup('name').aggregate(:sum => :score).process
    @report.get_subgroup_rows(1).should have(6).items
    @report.get_subgroup_rows(0).should have(1).items
    @report.get_subgroup_rows(0).first[:data][:score].should eql(151)
  end
  
  it "should be able to aggregate multiple columns into subgroup rows" do
    @report.sort('name').subgroup('name').aggregate(:sum => [:score, :age]).process
    data = @report.get_subgroup_rows(0).first[:data]
    data[:score].should eql(151)
    data[:age].should eql(294)

    @report.sort('name').subgroup('name').aggregate(:sum => :score, :average => :age).process
    data = @report.get_subgroup_rows(0).first[:data]
    data[:score].should eql(151)
    data[:age].should eql(29)
  end

  it "should be able to aggregate with :average, :product" do
    @report.sort('name').subgroup('name').aggregate(:average => :score).process
    @report.get_subgroup_rows(0).first[:data][:score].should eql(15)
    
    @report.sort('name').subgroup('name').aggregate(:product => :score).process
    @report.get_subgroup_rows(0).first[:data][:score].should eql(54428516352)
  end
  
  it "should be able to aggregate with :custom" do
    @report.sort('name').subgroup('name')
    @report.aggregate(Proc.new { |d| d.inject { |t, a| 2 * (t + a) } } => :score).process
    @report.get_subgroup_rows(0).first[:data][:score].should eql(19508)
  end

  it "should be able to style cells" do
    @report.process
    @report.style_cells('highlight') { |c, r| c == 32 }
    styles = @report.process_data.select { |r| r[:meta][:cell_styles] }
    styles.should have(2).items
  end

  it "should be able to style cells in certain columns" do
    @report.process
    @report.style_cells('highlight', :only => :age) { |c, r| c == 32 }
    @report.style_cells('big', :except => [:name, :day]) { |c, r| c.size > 2 }
    styles = @report.process_data.select { |r| r[:meta][:cell_styles] }
    styles.should have(10).items
    
    janet = @report.process_data.select { |r| r[:data].name == 'Janet' }.first
    jstyles = janet[:meta][:cell_styles]
    
    jstyles[:age].sort.join(',').should eql('big,highlight')
    jstyles[:score].should eql(["big"])
  end
  
  it "should be able to style rows" do
    @report.process
    @report.style_rows('over_thirty') { |row| row.age > 29 }
    @report.style_cells('highlight', :only => :age) { |c, r| c == 32 }
    
    janet = @report.process_data.select { |r| r[:data].name == 'Janet' }.first[:meta]
    janet[:row_styles].should eql(["over_thirty"])
    janet[:cell_styles].should have(1).item
    janet[:cell_styles][:age].should eql(["highlight"])
  end
  
  it "should be able to aggregate rows into new column"
  
  it "should be able to alias column titles"
  
end