require 'rubygems'
require 'sinatra'
require File.expand_path(File.dirname(__FILE__) + "/../lib/munger")

get '/' do
  report = Munger::Report.from_data(test_data).process
  out = Munger::Render.to_html(report, :classes => {:table => 'other-class'} )
  show(out)
end

get '/pivot' do
  data = Munger::Data.load_data(test_data)

  data.add_column([:advert, :rate]) do |row| 
    rate = (row.clicks / row.airtime)
    [row.advert.capitalize, rate]
  end

  new_columns = data.pivot('airtime', 'advert', 'rate', :average)

  report = Munger::Report.from_data(data)
  report.columns([:advert] + new_columns)
  report.process

  report.style_cells('myRed', :only => new_columns) { |cell, row| (cell.to_i < 10 && cell.to_i > 0) }

  out = Munger::Render.to_html(report, :classes => {:table => 'other-class'} )

  show(out)
end

get '/example' do
  data = Munger::Data.load_data(test_data)

  data.add_column([:advert, :rate]) do |row| 
    rate = (row.clicks / row.airtime)
    [row.advert.capitalize, rate]
  end

  #data.filter_rows { |row| row.rate > 10 }
  #new_columns = data.pivot('airtime', 'advert', 'rate', :average)

  report = Munger::Report.from_data(data)
  report.columns(:advert => 'Spot', :airdate => 'Air Date', :airtime => 'Airtime', :rate => 'Rate')
  report.sort = [['airtime', :asc], ['rate', :asc]]
  report.subgroup('airtime', :with_titles => true)
  report.aggregate(Proc.new {|arr| arr.inject(0) {|total, i| i * i + (total - 30) }} => :airtime, :average => :rate)
  report.process

  report.style_cells('myRed', :only => :rate) { |cell, row| (cell.to_i < 10) }

  out = Munger::Render.to_html(report, :classes => {:table => 'other-class'} )
  
  show(out)
end

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

def show(data)
%Q(
<html>
  <head>
    <style>
      .myRed { background: #e44; }

      tr.group0 { background: #bbb;}
      tr.group1 { background: #ddd;}

      tr.groupHeader1 { background: #ccc;}

      table tr td {padding: 0 15px;}
      table tr th { background: #aaa; padding: 5px; }
      body { font-family: verdana, "Lucida Grande", arial, helvetica, sans-serif;
        color: #333; }
    </style>
  </head>
  <body>
    #{data}
  </body>
</html>
)
end