source 'http://rubygems.org'

ruby '2.1.0'

gem 'bundler'

group :development do
  gem 'rake'
  gem 'foreman'
end

group :production do
  gem 'rack'
  gem 'rack_fast_escape', '2009.06.24'
  gem 'text'
  gem 'yajl-ruby', :require => 'yajl'
  gem 'procrastinate'
  gem 'cocoapods-core'
  gem 'unicorn'
  gem 'sinatra'
  gem 'picky', '~> 4.20.0'
  gem 'picky-client', '~> 4.20.0'
  gem 'newrelic_rpm'
end

group :test do
  gem 'rack-test'
  gem 'kicker'
  gem 'mocha', '~> 0.11.4'
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon', :git => 'https://github.com/irrationalfab/PrettyBacon.git', :branch => 'master'
end