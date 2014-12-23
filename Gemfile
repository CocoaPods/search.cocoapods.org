source 'http://rubygems.org'

ruby '2.1.3'

# Main gems used in all the application.
#
gem 'bundler'
gem 'sinatra', :require => 'sinatra/base'
# gem 'cocoapods-core'
gem 'picky', '~> 4.23.0'
gem 'picky-client', '~> 4.23.0' # Needed for Picky::Convenience
gem 'cod'
gem 'hashie'

# Database.
#
gem 'pg'
gem 'dm-core', require: true #, '>= 1.3.0.beta', github: 'technology-astronauts/dm-core'
gem 'dm-do-adapter', require: true
gem 'dm-postgres-adapter', require: true
gem 'flounder'

# Auxiliary gems to make Picky faster/better.
#
gem 'text'
gem 'rack_fast_escape', '2009.06.24'
gem 'yajl-ruby', :require => 'yajl'

# API calling
#
gem 'nap', '~> 0.8.0'

# Pure development gems.
#
group :development do
  gem 'rake'
  gem 'foreman'
  gem 'rubocop'
end

# Pure production gems.
#
group :production do
  gem 'unicorn'
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
