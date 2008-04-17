require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "munger"
    s.version   =   "0.1.2"
    s.author    =   "Scott Chacon"
    s.email     =   "schacon@gmail.com"
    s.summary   =   "A reporting engine in Ruby"
    s.files     =   FileList['lib/**/*', 'spec/**/*'].to_a

    s.homepage = "http://github/schacon/munger"

    s.require_path  =   "lib"
    s.test_files = Dir.glob('spec/*.rb')
    s.has_rdoc  =   true
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

