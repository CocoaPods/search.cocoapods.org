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
  `bundle update`
  Process.kill :KILL, Process.pid
end

run CocoapodSearch