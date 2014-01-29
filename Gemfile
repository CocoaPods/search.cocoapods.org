source 'http://rubygems.org'

ruby '2.0.0'

gem 'bundler'
gem 'rake'
gem 'rack'
gem 'rack_fast_escape', '2009.06.24'
gem 'text'
gem 'yajl-ruby', :require => 'yajl'
gem 'procrastinate'
gem 'cocoapods-core'
gem 'unicorn'
gem 'sinatra'
gem 'picky', '~> 4.19'
gem 'picky-client', '~> 4.19'

group :development do
  gem 'foreman'
end

group :test do
  gem 'rack-test'
  gem 'kicker'
  gem 'mocha', '~> 0.11.4'
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon', :git => 'https://github.com/irrationalfab/PrettyBacon.git', :branch => 'master'
end

group :production do
  gem 'newrelic_rpm'
end