require File.dirname(__FILE__) + "/../spec_helper"

describe Munger::Item do 
  include MungerSpecHelper
  
  before(:all) do 
    @data = Munger::Data.new(:data => test_data)
  end

  it "should accept a hash with symbols" do
    hash = {'key1' => 'value1', 'key2' => 'value2'}
    item = Munger::Item.ensure(hash)
    item.key1.should eql('value1')
  end
  
  it "should accept a hash with strings" do
    hash = {:key1 => 'value1', :key2 => 'value2'}
    item = Munger::Item.ensure(hash)
    item.key1.should eql('value1')
    item.key2.should_not eql('value1')
    item.key3.should be(nil)
  end

  it "should accept mixed types" do
    hash = {:key1 => 'value1', 'key2' => 'value2'}
    item = Munger::Item.ensure(hash)
    item.key1.should eql('value1')
    item.key2.should eql('value2')
  end

  it "should be able to access hash values indifferently" do
    hash = {:key1 => 'value1', 'key2' => 'value2'}
    item = Munger::Item.ensure(hash)
    item['key1'].should eql('value1')
    item[:key2].should eql('value2')
  end
end