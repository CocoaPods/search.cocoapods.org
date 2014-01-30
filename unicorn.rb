pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'tmp/unicorn.stderr.log'
stdout_path       'tmp/unicorn.stdout.log'
timeout           10
worker_processes  3

# As an experiment:
#
# Before we fork (each child, sadly), we do
# a preflight request so that certain lazily
# instantiated Picky/other resources
# can be shared between workers.
#
once_upon_a_time = true
before_fork do |server, worker|
  if once_upon_a_time
    CocoapodSearch.call 'REQUEST_METHOD' => 'GET',
                        'PATH_INFO' => '/api/v1/pods.picky.hash.json',
                        'QUERY_STRING' => 'query=test',
                        'rack.input' => StringIO.new
    once_upon_a_time = false
  end
end