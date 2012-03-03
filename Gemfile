# We don't install CocoaPods as a gem, but rather vendor it as a git submodule.
# The reason for this is that we don't need the Xcodeproj dependency and in
# fact makes it even impossible to install on Heroku.

source :gemcutter

gem 'bundler'

# Gems required by the Picky client.
#
gem 'picky-client', '~> 4'
gem 'i18n'
gem 'activesupport', :require => 'active_support/core_ext'
gem 'sinatra'

# Gems required by the Picky server.
#
gem 'picky', '~> 4'
gem 'rake'
gem 'rack'
gem 'rack_fast_escape', '2009.06.24' # Optional.
gem 'text'
gem 'yajl-ruby', :require => 'yajl'

# Should be optional, but isn't yet.
#
gem 'activerecord',  '~> 3.0', :require => 'active_record'

# Required by your project.
#
gem 'thin'

group :test do
  gem 'rspec'
end
