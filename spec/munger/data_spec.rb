require File.dirname(__FILE__) + "/../spec_helper"

describe Munger::Data do 
  include MungerSpecHelper
  
  before(:each) do 
    @data = Munger::Data.new(:data => test_data)
  end

  it "should accept an array of hashes" do
    Munger::Data.new(:data => test_data).should be_valid
  end
  
  it "should be able to set data after init" do
    m = Munger::Data.new
    m.data = test_data
    m.should be_valid
  end
  
  it "should be able to set data in init block" do
    m = Munger::Data.new do |d|
      d.data = test_data
    end
    m.should be_valid
  end
  
  it "should be able to extract columns from data" do
    @titles = @data.columns
    @titles.should have(4).items
    @titles.should include(:name, :score, :age)
  end

  it "should be able to add a new column with a default value" do
    @data.add_column('new_column', :default => 1)
    @data.data.first['new_column'].should eql(1)
  end
  
  it "should be able to add a new column with a block" do
    @data.add_column('new_column') { |c| c.age + 1 }
    @data.data.first['new_column'].should eql(24)
  end

  it "should be able to add multiple new columns with defaults" do
    @data.add_column(['col1', 'col2'], :default => [1, 2])
    @data.data.first['col1'].should eql(1)
    @data.data.first['col2'].should eql(2)
  end
  
  it "should be able to add multiple new columns with a block" do
    @data.add_column(['col1', 'col2']) { |c| [c.age * 2, c.score * 3]}
    @data.data.first['col1'].should eql(46)
    @data.data.first['col2'].should eql(36)
  end
    
  it "should work with add_columns, too" do
    @data.add_columns(['col1', 'col2'], :default => [1, 2])
    @data.data.first['col1'].should eql(1)
    @data.data.first['col2'].should eql(2)
  end
  
  it "should be able to transform a column" do
    @data.data.first[:age].should eql(23)
    @data.transform_column(:age) { |c| c.age * 2 }
    @data.data.first[:age].should eql(46)
  end
  
  it "should be able to transform multiple rows" do
    @data.data.first[:age].should eql(23)
    @data.data.first[:score].should eql(12)
    @data.transform_columns([:age, :score]) { |c| [c.age * 2, c.score * 3] }
    @data.data.first[:age].should eql(46)
    @data.data.first[:score].should eql(36)
  end

  it "should be able to filter the data down" do
    orig_size = @data.size
    @data.filter_rows { |r| r.age < 30 }
    @data.size.should < orig_size
    @data.size.should eql(4)
  end
  
  it "should be able to pivot the data (1 column)" do
    orig_size = @data.size
    new_keys = @data.pivot(:day, :name, :score)
    @data.size.should < orig_size
    new_keys.should include(1, 2)
    scott = @data.data.select { |r| r.name == 'Scott' }.first
    scott[1].should eql(43)
  end

  it "should be able to pivot the data with average aggregation" do
    new_keys = @data.pivot(:day, :name, :score, :average)
    new_keys.should include(1, 2)
    scott = @data.data.select { |r| r.name == 'Scott' }.first
    scott[1].should eql(21)
  end
  
  it "should be able to pivot the data with count aggregation" do
    new_keys = @data.pivot(:day, :name, :score, :count)
    scott = @data.data.select { |r| r.name == 'Scott' }.first
    scott[1].should eql(2)
  end

  it "should be able to pivot the data in three dimensions (1 col, 2 row)" do
    new_keys = @data.pivot(:name, [:score, :age], :score, :count)
    alice = @data.data.select { |r| r.name == 'Alice' }.first
    alice.Alice.should eql(2)
  end

  # like sql group command, give aggregation block
  it "should be able to group the data like sql" do
    @data.group(:name)
    @data.size.should eql(6)
  end
  
  it "should be able to group on multiple columns" do
    @data.group([:age, :score], :count => :day, :sum => :day, :average => :score)
    alice = @data.data.select { |r| (r.score == 12) && (r.age == 33)}.first
    alice.count_day.should eql(2)
    alice.sum_day.should eql(3)
    alice.average_day.should eql(nil)
  end

  it "should be able to group with a proc aggregation" do
    pr = Proc.new {|arr| arr.inject(0) { |a,b| a + (b*2) }}
    @data.group([:age, :score], :sum => :day, ['test', pr] => :age)    
    alice = @data.data.select { |r| (r.score == 12) && (r.age == 33)}.first
    alice.test_age.should eql(132)
    alice.sum_day.should eql(3)
  end

  it "should be able to pivot the data in three dimensions (2 col, 1 row)"
  
  it "should be able to pivot the data in four dimensions (2 col, 2 row)"
    
  it "should be able to add two Munger::Datas together if they have the same columns"
  
  it "(maybe) should be able to zip two Munger::Datas together given a unique key column in each"
  
end