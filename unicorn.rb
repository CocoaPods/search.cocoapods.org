listen            '0.0.0.0:8080'
pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'log/unicorn.stderr.log'
stdout_path       'log/unicorn.stdout.log'
timeout           10
worker_processes  3