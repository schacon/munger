require File.expand_path(File.dirname(__FILE__) + "/../lib/munger")

require 'fileutils'
require 'logger'
require 'pp'

module ExampleHelper
  def test_data
    [
      {:advert => "spot 1", :airtime => 15, :airdate => "2008-01-01", :clicks => 301},
      {:advert => "spot 1", :airtime => 30, :airdate => "2008-01-02", :clicks => 199},
      {:advert => "spot 1", :airtime => 30, :airdate => "2008-01-03", :clicks => 234},
      {:advert => "spot 1", :airtime => 15, :airdate => "2008-01-04", :clicks => 342},
      {:advert => "spot 2", :airtime => 30, :airdate => "2008-01-01", :clicks => 172},
      {:advert => "spot 2", :airtime => 15, :airdate => "2008-01-02", :clicks => 217},
      {:advert => "spot 2", :airtime => 90, :airdate => "2008-01-03", :clicks => 1023},
      {:advert => "spot 2", :airtime => 30, :airdate => "2008-01-04", :clicks => 321},
      {:advert => "spot 3", :airtime => 60, :airdate => "2008-01-01", :clicks => 512},
      {:advert => "spot 3", :airtime => 30, :airdate => "2008-01-02", :clicks => 813},
      {:advert => "spot 3", :airtime => 15, :airdate => "2008-01-03", :clicks => 333},
    ]
  end
end