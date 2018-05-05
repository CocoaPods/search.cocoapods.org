source 'https://rubygems.org'

if ENV['RACK_ENV'] == 'production' || ENV['CI'] == 'true'
  ruby File.read(File.expand_path('../.ruby-version', __FILE__)).strip
end

# Debug.
#
# gem 'memory_profiler'

# Main gems used in all the application.
#
gem 'bundler'
gem 'sinatra', '1.4.5', :require => 'sinatra/base'
gem 'picky', '~> 4.31.0'
gem 'picky-client', '~> 4.31.0' # Needed for Picky::Convenience
gem 'cod', '0.6.0'
gem 'hashie', '3.3.2'
# gem 'google_hash', '0.8.8'
gem 'cocoapods-core', "~> 1.0"

# Auxiliary gems to make Picky faster/better.
#
gem 'rack_fast_escape', '2009.06.24'
gem 'yajl-ruby', :require => 'yajl'
gem 'ruby-stemmer', :require => 'lingua/stemmer'

# Database.
#
gem 'pg', '0.18.1'
gem 'dm-postgres-adapter', '1.2.0', require: true
gem 'flounder', '1.0.1'

# API calling.
#
gem 'nap', '~> 1.0'

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
  gem 'unicorn', '4.8.3'
end


# Pure test gems.
#
group :test do
  gem 'cocoapods-humus', :require => false
  gem 'memory_profiler'
  gem 'rack-test'
  gem 'kicker'
  gem 'mocha', '~> 0.11.4'
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon', :git => 'https://github.com/irrationalfab/PrettyBacon.git', :branch => 'master', :require => 'pretty_bacon'
end
