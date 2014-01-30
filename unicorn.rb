pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'tmp/unicorn.stderr.log'
stdout_path       'tmp/unicorn.stdout.log'
timeout           10
worker_processes  3

once_upon_a_time = true
before_fork do |server, worker|
  # As an experiment:
  #
  # Before we fork (each child, sadly), we do
  # a preflight request so that certain lazily
  # instantiated Picky/other resources
  # can be shared between workers.
  #
  if once_upon_a_time
    CocoapodSearch.call 'REQUEST_METHOD' => 'GET',
                        'PATH_INFO' => '/api/v1/pods.picky.hash.json',
                        'QUERY_STRING' => 'query=test',
                        'rack.input' => StringIO.new
    once_upon_a_time = false
  end
  
  # If our parent is an old unicorn, we will kill it off using WINCH, then QUIT.
  #
  # Note: This means a previous master used USR2 to start me.
  #
  
  # Is there an old unicorn, waiting to be put down?
  #
  oldpid_path = 'tmp/pids/unicorn.pid.oldbin'
  if File.exists? oldpid_path
    File.open oldpid_path do |pidfile|
      old_unicorn_pid = Integer(pidfile.read.chomp)
      parent_pid      = Process.ppid
      
      # Is my parent actually that unicorn?
      #
      if old_unicorn_pid == parent_pid
        
        # Patricide go!
        #
        Process.kill 'WINCH', parent_pid
        Process.kill 'QUIT', parent_pid
      end
    end
  end
  
  # We catch TERM from Heroku and try to do a no-downtime restart.
  #
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting the Heroku TERM and sending myself USR2 instead.'
    
    # Dump the indexes to be picked up by the new Unicorn master.
    #
    CocoapodSearch.dump_indexes
    
    # USR2 will start a new master.
    #
    Process.kill 'USR2', Process.pid
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
end