Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "munger"
    s.version   =   "0.1.3.1"
    s.author    =   "[Scott Chacon, Don Morrison]"
    s.email     =   "elskwid@gmail.com"
    s.summary   =   "A reporting engine in Ruby (El Skwid fork)"
    s.homepage = "http://github/elskwid/munger"
    s.has_rdoc  =   true
    s.files = ["munger.gemspec",
               "Rakefile",
               "README",
               "examples/column_add.rb",
               "examples/development.log",
               "examples/example_helper.rb",
               "examples/sinatra.rb",
               "examples/test.html",
               "lib/munger.rb",
               "lib/munger/data.rb",
               "lib/munger/item.rb",
               "lib/munger/render.rb",
               "lib/munger/report.rb",
               "lib/munger/render/html.rb",
               "lib/munger/render/sortable_html.rb",
               "lib/munger/render/text.rb",
               "spec/spec_base.rb",
               "spec/spec_data.rb",
               "spec/spec_helper.rb",
               "spec/spec_item.rb",
               "spec/spec_render.rb",
               "spec/spec_render_html.rb",
               "spec/spec_render_text.rb",
               "spec/spec_report.rb"]
end