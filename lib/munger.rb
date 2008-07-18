$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'munger/data'
require 'munger/report'
require 'munger/item'

require 'munger/render'
require 'munger/render/csv'
require 'munger/render/html'
require 'munger/render/sortable_html'
require 'munger/render/text'

module Munger
  VERSION = '0.1.3'
end
