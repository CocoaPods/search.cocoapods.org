# This is an interface that provides the user of
# Picky with the possibility to change parameters
# while the Application is running.
#
class Master

  class CouldNotRunError < StandardError; end
  
  # The :try_in_child option determines if work is pre-run in a child
  # before running it in a master. This makes the server
  # more resistant against errors from the code that is run.
  #
  # The block work is a block that is called in the child/master.
  # it receives a true if it is a child index, a false if master.
  #
  def initialize options = {}, &work
    @child, @parent = IO.pipe
    @try_in_child = options[:try_in_child] != false
    @work = work
    start_master_process_thread
  end
  
  # First tries to reindex in the child, and if
  # successful, sends a message to the parent to
  # do work there.
  #
  # Note: Currently one can only send 'reindex'.
  #
  # Note: This is the method one should use.
  #
  def run message
    close_child # We close the child pipe lazily.
    if @try_in_child
      STDOUT.puts "Trying to run work in CHILD."
      try_run # We may do a "try run".
    end
    write_parent message # Then we trigger reindexing in the parent.
  rescue CouldNotRunError => e
    # I need to die such that my broken state is never used.
    #
    STDOUT.puts "Child process #{Process.pid} performs harakiri because of errors in the 'try run'."
    harakiri
  end

  # This runs a thread that listens to child processes.
  #
  def start_master_process_thread
    # This thread is implicitly stopped in the children.
    #
    Thread.new do
      loop do
        # Wait for input from the child.
        #
        IO.select([@child], nil, nil, 2) or next
        
        # Get the result and decide what to do.
        #
        # Note: Currently we do exactly one thing.
        #
        
        # Get all data up and including ;;;.
        #
        result = @child.gets ';;;'
        
        # Get the child's PID and the message.
        #
        pid, message = eval result
        case message
        when 'reindex' # TODO This is currently hardcoded, but needs to be dynamic.
          STDOUT.puts "Trying to run work in MASTER."
          
          # Try work in the master.
          #
          try_run
          
          # Kill all kids except the one we already successfully reindexed.
          #
          # If we do not try in child, kill all.
          #
          kill_each_worker_except @try_in_child ? pid : 'nonexistent pid'
        end

        # Fails hard on an error.
        #
      end
    end
  end

  # Taken from Unicorn.
  #
  def kill_each_worker_except pid
    worker_pids.each do |wpid|
      next if wpid == pid
      kill_worker :KILL, wpid
    end
  end
  def kill_worker signal, wpid
    Process.kill signal, wpid
    STDOUT.puts "Killing worker ##{wpid} with signal #{signal}."
  rescue Errno::ESRCH
    remove_worker wpid
  end
  
  # Unicorn-specific helper methods.
  #
  def worker_pids
    Unicorn::HttpServer::WORKERS.keys
  end
  def remove_worker wpid
    worker = Unicorn::HttpServer::WORKERS.delete(wpid) and worker.tmp.close rescue nil
  end
  
  # Kills itself, but still answering the current request honorably.
  #
  def harakiri
    Process.kill :QUIT, Process.pid
  end
  
  # Write the parent.
  #
  # Note: The ;;; is the end marker for the message.
  #
  def write_parent message
    @parent.write "#{[Process.pid, message]};;;"
  end
  
  # Close the child if it isn't yet closed.
  #
  def close_child
    @child.close unless @child.closed?
  end

  # Tries calling the work job in the child process or parent process.
  #
  def try_run
    begin
      @work.call @child.closed?
    rescue StandardError => e
      # Catch any error and reraise as a "could not run" error.
      #
      raise CouldNotRunError.new
    end
  end

end