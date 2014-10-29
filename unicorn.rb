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
  CocoapodSearch.child = true
end