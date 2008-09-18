require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "munger"
    s.version   =   "0.1.3"
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

desc 'Run specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--format', 'specdoc', '--colour', '--diff']
end

desc 'Generate coverage reports'
Spec::Rake::SpecTask.new('spec:coverage') do |t|
  t.rcov = true
end

desc 'Generate a nice HTML report of spec results'
Spec::Rake::SpecTask.new('spec:report') do |t|
  t.spec_opts = ['--format', 'html:report.html', '--diff']
end

task :doc => [:rdoc]
namespace :doc do
  Rake::RDocTask.new do |rdoc|
    files = ["README", "lib/**/*.rb"]
    rdoc.rdoc_files.add(files)
    rdoc.main = "README"
    rdoc.title = "Munger Docs"
    rdoc.rdoc_dir = "doc"
    rdoc.options << "--line-numbers" << "--inline-source"
  end
end
