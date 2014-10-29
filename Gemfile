source 'http://rubygems.org'

ruby '2.1.3'

# Main gems used in all the application.
#
gem 'bundler'
gem 'sinatra', :require => 'sinatra/base'
# gem 'cocoapods-core'
gem 'picky', '~> 4.22.0'
gem 'picky-client', '~> 4.22.0' # Needed for Picky::Convenience
gem 'cod'
gem 'hashie'

# Database.
#
gem 'pg'
gem 'dm-core',             '>= 1.3.0.beta', require: true, git: 'https://github.com/technology-astronauts/dm-core.git'
gem 'dm-do-adapter',       '>= 1.3.0.beta', require: true
gem 'dm-postgres-adapter', '>= 1.3.0.beta', require: true
gem 'flounder'

# Auxiliary gems to make Picky faster/better.
#
gem 'text'
gem 'rack_fast_escape', '2009.06.24'
gem 'yajl-ruby', :require => 'yajl'

# Pure development gems.
#
group :development do
  gem 'rake'
  gem 'foreman'
end

# Pure production gems.
#
group :production do
  gem 'unicorn'
  gem 'newrelic_rpm'
  gem 'gabba'
end

# Pure test gems.
#
group :test do
  gem 'rack-test'
  gem 'kicker'
  gem 'mocha', '~> 0.11.4'
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon', :git => 'https://github.com/irrationalfab/PrettyBacon.git', :branch => 'master', :require => 'pretty_bacon'
end
