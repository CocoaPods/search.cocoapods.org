number_of_worker_processes = 3

pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'tmp/unicorn.stderr.log'
stdout_path       'tmp/unicorn.stdout.log'
timeout           10
worker_processes  number_of_worker_processes

done = false

before_fork do |_, _|
  unless done
    # For communication between n worker - 1 search engine processes.
    Channel.
      instance(:search).
      start children: number_of_worker_processes, worker: SearchWorker
    Channel.
      instance(:analytics).
      start children: number_of_worker_processes, worker: AnalyticsWorker
    done = true
  end
end

after_fork do |server, worker|
  Channel.instance(:search).choose_channel worker.nr
  Channel.instance(:analytics).choose_channel worker.nr
  
  # Load the DB after forking.
  #
  require File.expand_path '../lib/database', __FILE__
  
  # We are a child.
  #
  CocoapodSearch.child = true
end