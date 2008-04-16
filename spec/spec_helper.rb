require File.expand_path(File.dirname(__FILE__) + "/../lib/munger")

require 'rubygems'
require 'spec'
require 'fileutils'
require 'logger'
require 'pp'

module MungerSpecHelper
  def test_data
    [{:name => 'Scott', :age => 23, :day => 1, :score => 12},
     {:name => 'Chaz',  :age => 28, :day => 1, :score => 12},
     {:name => 'Scott', :age => 23, :day => 2, :score => 1},
     {:name => 'Janet', :age => 32, :day => 2, :score => 24},
     {:name => 'Rich', :age => 32, :day => 2, :score => 14},
     {:name => 'Gordon', :age => 33, :day => 1, :score => 21},
     {:name => 'Scott', :age => 23, :day => 1, :score => 31},
     {:name => 'Alice', :age => 33, :day => 1, :score => 12},
     {:name => 'Alice', :age => 34, :day => 2, :score => 12},
     {:name => 'Alice', :age => 33, :day => 2, :score => 12},
      ]
  end
  
  def invalid_test_data
    ['one', 'two', 'three']
  end
end

  

##
# rSpec Hash additions.
#
# From 
#   * http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
#   * Neil Rahilly

class Hash

  ##
  # Filter keys out of a Hash.
  #
  #   { :a => 1, :b => 2, :c => 3 }.except(:a)
  #   => { :b => 2, :c => 3 }

  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  ##
  # Override some keys.
  #
  #   { :a => 1, :b => 2, :c => 3 }.with(:a => 4)
  #   => { :a => 4, :b => 2, :c => 3 }
  
  def with(overrides = {})
    self.merge overrides
  end

  ##
  # Returns a Hash with only the pairs identified by +keys+.
  #
  #   { :a => 1, :b => 2, :c => 3 }.only(:a)
  #   => { :a => 1 }
  
  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym) }
  end

end

