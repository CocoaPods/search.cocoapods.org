number_of_worker_processes = 2

pid 'tmp/pids/unicorn.pid'
preload_app true # This means we need to reople DB connections etc.
stderr_path 'tmp/unicorn.stderr.log'
stdout_path 'tmp/unicorn.stdout.log'
logger Logger.new(STDOUT)
timeout 10
worker_processes number_of_worker_processes

# Before forking off child workers, we start a
# process each for searching and sending data
# to analytics. (this opens up n pipes for communication)
#
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

# After working web worker, we mainly do:
#
# * Web worker chooses a channel each to
#   communicate with the search and analytics
#   process.
#
# If a worker is restarted, e.g. because of a
# timeout, it gets one of the free numbers
# (usually just the one the worker had before).
# So there won't ever be collisions.
#
after_fork do |_server, worker|
  Channel.instance(:search).choose_channel worker.nr
  Channel.instance(:analytics).choose_channel worker.nr

  # Load the DB after forking.
  #
  require File.expand_path '../lib/database', __FILE__

  # We are a web worker child.
  # This is used to decide whether
  # a search request should be send to
  # the search process (child) or not
  # (not a child).
  #
  CocoapodSearch.child = true
end
