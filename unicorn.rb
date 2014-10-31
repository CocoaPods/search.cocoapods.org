number_of_worker_processes = 3

pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'tmp/unicorn.stderr.log'
stdout_path       'tmp/unicorn.stdout.log'
timeout           10
worker_processes  number_of_worker_processes

before_fork do |_, _|
  # For communication between n worker - 1 search engine processes.
  Channel.instance.master_setup_number_of_children number_of_worker_processes
end

after_fork do |server, worker|
  Channel.instance.child_choose_channel worker.nr
  
  # Load the DB after forking.
  #
  require File.expand_path '../lib/database', __FILE__
  
  # We are a child.
  #
  CocoapodSearch.child = true
end