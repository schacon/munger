module Munger #:nodoc:
  
  class Item
    
    attr_reader :data
    
    def initialize(data)
      @data = data
    end
    
    def [](key)
      return @data[key] if @data[key]
      if key.is_a? Symbol
        return @data[key.to_s] if @data[key.to_s]
      elsif key.is_a? String
        return @data[key.to_sym] if @data[key.to_sym]
      end
    end
    
    def []=(key, value)
      @data[key] = value
    end
    
    def method_missing( id, *args )
      if @data[id].nil?
        m = id.to_s
        if /=$/ =~ m
    		  @data[m.chomp!] = (args.length < 2 ? args[0] : args)
    	  else
    		  @data[m]
    	  end
      else
        @data[id]
      end
    end
    
    def self.ensure(item)
      if item.is_a? Munger::Item
        return item
      else
        return Item.new(item)
      end
    end
    
    def to_hash
      @data
    end
    
  end
end