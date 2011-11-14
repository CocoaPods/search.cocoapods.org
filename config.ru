require File.expand_path '../app', __FILE__

begin
  CocoapodSearch.prepare
rescue Exception => e
  # Try to bundle update and harakiri.
  #
  # Heroku will instantly try to restart.
  # If it doesn't work, it will periodically try.
  #
  warn "There was a problem, possibly with an outdated version of cocoapods. Updating bundles and restarting."
  require 'bundler'
  require 'bundler/cli'
  Bundler::CLI.new.update
  raise "For glory!"
end

run CocoapodSearch