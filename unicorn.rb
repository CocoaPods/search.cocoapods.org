pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'tmp/unicorn.stderr.log'
stdout_path       'tmp/unicorn.stdout.log'
# timeout           10 # We don't have a timeout to allow pre-reindexing in a child.
worker_processes  4