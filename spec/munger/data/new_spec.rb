require File.dirname(__FILE__) + '/../../spec_helper'

describe Munger::Data do
  
  describe '.new' do
    
    it 'initializes the data attribute to the :data value' do
      data = [{:foo => '1'}, {:foo => 2}]
      Munger::Data.new(:data => data).data.should == data
    end
    
    it 'yields itself to the given block' do
      Munger::Data.new { |data| data.should be_kind_of(Munger::Data) }
    end
    
  end
  
end