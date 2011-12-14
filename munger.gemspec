Gem::Specification.new do |s|
    s.platform  =  Gem::Platform::RUBY
    s.name      =  "munger"
    s.version   =  "0.1.4"
    s.authors   =  ['Scott Chacon', 'Brandon Mitchell', 'Don Morrison', 'Eric Lindvall']
    s.email     =  "schacon@gmail.com"
    s.summary   =  "A reporting engine in Ruby"
    s.homepage  =  "http://github/schacon/munger"
    s.has_rdoc  =  true
    s.files = ["munger.gemspec",
               "Rakefile",
               "README",
               "examples/column_add.rb",
               "examples/development.log",
               "examples/example_helper.rb",
               "examples/sinatra_app.rb",
               "examples/test.html",
               "lib/munger.rb",
               "lib/munger/data.rb",
               "lib/munger/item.rb",
               "lib/munger/render.rb",
               "lib/munger/report.rb",
               "lib/munger/render/html.rb",
               "lib/munger/render/sortable_html.rb",
               "lib/munger/render/text.rb",
               "lib/munger/render/csv.rb",
               "spec/spec_helper.rb",
               "spec/munger/data_spec.rb",
               "spec/munger/item_spec.rb",
               "spec/munger/render_spec.rb",
               "spec/munger/report_spec.rb",
               "spec/munger/data/new_spec.rb",
               "spec/munger/render/csv_spec.rb",
               "spec/munger/render/html_spec.rb",
               "spec/munger/render/text_spec.rb"]
end
