source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'will_paginate'
gem 'dalli', :git => 'git://github.com/mperham/dalli.git'

gem 'execjs'
gem 'json'
gem 'therubyracer', :platforms => :ruby
gem 'eventmachine', '~>1.0.0.beta.4'
gem 'thin'

gem 'jquery-rails'

gem 'closure-compiler'

gem 'newrelic_rpm'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.4'
end


group :production do


  gem 'pg'
end

group :test do
  gem 'sqlite3'
  gem 'spork'
  gem 'rspec-rails'
  gem 'watchr'
  gem 'webrat'
end

group :development do
  gem 'sqlite3'
  #gem 'spork'
  gem 'annotate'
  gem 'rspec-rails'
  gem 'watchr'
  gem 'webrat'
  gem 'term-ansicolor'
  gem 'query_trace'

end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
