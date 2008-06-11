Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "munger"
    s.version   =   "0.1.3.1"
    s.author    =   "[Scott Chacon, Don Morrison]"
    s.email     =   "elskwid@gmail.com"
    s.summary   =   "A reporting engine in Ruby (El Skwid fork)"
    s.files     =   FileList['lib/**/*', 'spec/**/*'].to_a

    s.homepage = "http://github/elskwid/munger"

    s.require_path  =   "lib"
    s.test_files = Dir.glob('spec/*.rb')
    s.has_rdoc  =   true
end