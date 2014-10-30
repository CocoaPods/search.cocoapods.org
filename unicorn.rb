pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'tmp/unicorn.stderr.log'
stdout_path       'tmp/unicorn.stdout.log'
timeout           10
worker_processes  3

before_fork do |_, _|
  Channel.instance # For communication between n worker - 1 search engine processes.
end

after_fork do |server, worker|
  # Load the DB after forking.
  #
  require File.expand_path '../lib/database', __FILE__
  
  # We are a child.
  #
  CocoapodSearch.child = true
end