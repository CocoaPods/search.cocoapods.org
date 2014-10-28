# This is an interface that provides the user of
# Picky with the possibility to change parameters
# while the Application is running.
#
class Master

  class CouldNotRunError < StandardError; end

  # The :try_in_child option determines if work is pre-run in a child
  # before running it in a master. This makes the server
  # more resistent against errors from the code that is run.
  #
  # The block work is a block that is called in the child/master.
  # it receives a true if it is a child index, a false if master.
  #
  def initialize search
    @child, @parent = IO.pipe
    @search = search
    start_master_process_thread
  end

  # Sends a message to the parent to do work there.
  #
  # Note: This is the method one should use.
  #
  def call action, message
    close_child # We close the child pipe lazily.
    write_parent action, message # Then we trigger reindexing in the parent.
  # rescue CouldNotRunError => e
  #   # I need to die such that my broken state is never used.
  #   #
  #   STDOUT.puts "Child process #{Process.pid} performs harakiri because of errors in the 'try run'."
  #   harakiri
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
        IO.select([@child], nil) or next

        # Get the result and decide what to do.
        #

        # Get all data up and including ;;;.
        #
        result = @child.gets ';;;'

        # Get the child's PID and the message.
        #
        pid, action, message = eval result
        case action
        when 'search'
          
        when 'reindex'
          # The message is a pod name.
          #
          STDOUT.puts "Reindexing #{message} in MASTER."
          try_indexing message
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
  def write_parent action, message
    @parent.write "#{[Process.pid, action, message]};;;"
  end

  # Close the child if it isn't yet closed.
  #
  def close_child
    @child.close unless @child.closed?
  end

  # Tries calling the work job in the child process or parent process.
  #
  def try_indexing name
    begin
      STDOUT.puts name
      pod = Pod.all { |pods| pods.where(:name => name) }.first
      @search.index.replace pod
      STDOUT.puts "Reindexing #{name} in MASTER successful."
    rescue StandardError => e
      # Catch any error and reraise as a "could not run" error.
      #
      STDOUT.puts "Reindexing #{name} in MASTER failed."
      raise CouldNotRunError.new
    end
  end

end