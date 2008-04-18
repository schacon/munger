require File.dirname(__FILE__) + "/example_helper"
include ExampleHelper

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
#report.subgroup('airtime')
#report.aggregate(Proc.new {|arr| arr.inject(0) {|total, i| i * i + (total - 30) }} => :airtime, :avg => :rate)
report.process

report.style_cells('myRed', :only => :rate) { |cell, row| (cell.to_i < 10) }

#puts html = Munger::Render.to_html(report, :classes => {:table => 'other-class'} )
puts text = Munger::Render.to_text(report)


f = File.open('test.html', 'w')
f.write(html)
f.close