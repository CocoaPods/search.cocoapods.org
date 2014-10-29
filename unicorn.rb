pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'tmp/unicorn.stderr.log'
stdout_path       'tmp/unicorn.stdout.log'
timeout           10
worker_processes  3

before_fork do |_, _|
  Master.instance # For communication between parent/child processes.
end

after_fork do |server, worker|
  # Signal.trap 'TERM' do
  #   puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  # end
  ::CHILD = true
end