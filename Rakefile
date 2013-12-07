require 'picky/tasks'

task :default => :spec

begin
  require 'rspec'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new :spec
rescue
  # Triggered on Heroku.
  # See https://devcenter.heroku.com/changelog-items/363.
end