# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'

$LOAD_PATH.unshift('lib')
require 'pdf/reader/turtletext/version'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "pdf-reader-turtletext"
  gem.version = PDF::Reader::Turtletext::Version::STRING
  gem.homepage = "https://github.com/tardate/pdf-reader-turtletext"
  gem.license = "MIT"
  gem.summary = %Q{PDF structured text reader}
  gem.description = %Q{a library that can read structured and positional text from PDFs. Ideal for asembling structured data from invoices and the like.}
  gem.email = "gallagher.paul@gmail.com"
  gem.authors = ["Paul Gallagher"]
  gem.files.exclude 'pkg/*'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

desc "Run all RSpec test examples"
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = ["-c", "-f progress"]
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pdf-reader-turtletext #{PDF::Reader::Turtletext::Version::STRING}"
  rdoc.rdoc_files.include('README*', 'lib/**/*.rb')
end
