source "http://rubygems.org"

gem 'pdf-reader', '>= 1.1.1', '<= 1.2' # works upto 1.2

group :development do
  gem 'bundler', '~> 1.1'
  gem 'jeweler', '~> 1.6'
end

group :development, :test do
  gem 'rake', '~> 0.9'
  gem 'rspec', '~> 2.8', :require => 'spec'
  gem 'rdoc', '~> 3.11'
  # prawn for generating PDFs for tests
  gem 'prawn', '~> 0.12'
  # guard for auto-running tests
  gem 'guard-rspec', '~> 1.2'
end