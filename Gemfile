source 'http://rubygems.org'

ruby '2.2.0'

# Debug.
#
# gem 'memory_profiler'

# Main gems used in all the application.
#
gem 'bundler'
gem 'sinatra', :require => 'sinatra/base'
# gem 'cocoapods-core'
gem 'picky', '~> 4.26.0'
gem 'picky-client', '~> 4.26.0' # Needed for Picky::Convenience
gem 'cod'
gem 'hashie'

# Database.
#
gem 'pg'
gem 'dm-postgres-adapter', require: true
gem 'flounder'

# Auxiliary gems to make Picky faster/better.
#
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
