require 'cod'

# This is an interface that provides the user of
# Picky with the possibility to change parameters
# while the Application is running.
#
class Master
  
  def self.instance
    @master ||= Master.new
  end

  class CouldNotRunError < StandardError; end

  # The :try_in_child option determines if work is pre-run in a child
  # before running it in a master. This makes the server
  # more resistent against errors from the code that is run.
  #
  # The block work is a block that is called in the child/master.
  # it receives a true if it is a child index, a false if master.
  #
  def initialize
    @up = Cod.pipe # For talking to the master process.
    @down = Cod.pipe # For talking to a child process.
    start_master_process_thread
  end

  # Sends a message to the parent to do work there.
  #
  # Note: This is the method one should use.
  #
  def call action, message
    # close_child # We close the child pipe lazily.
    write_parent action, message
  end

  # This runs a thread that listens to child processes.
  #
  def start_master_process_thread
    # This thread is implicitly stopped in the children.
    #
    Thread.new do
      # Index the DB.
      #
      STDOUT.puts "Indexing DB in MASTER."
      Search.instance.reindex
      STDOUT.puts "Finished indexing DB in MASTER."
      
      loop do
        # Wait for input from the child.
        #
        down, pid, action, message = @up.get
        STDOUT.puts [pid, action, message]
        case action
        when 'search'
          # The message is the parameters.
          #
          results = Search.instance(Pods.instance).search *message
          begin
            down.put results.to_hash
          rescue StandardError => e
            STDOUT.puts e.message
          end
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

  # Write the parent.
  #
  # Note: Sends itself so the parent can answer!
  #
  def write_parent action, message
    p message
    p [:up1, action, @up]
    p [:down1, action, @down]
    @up.put [@down, Process.pid, action, message]
    p [:up2, action, @up]
    p [:down2, action, @down]
    @down.get
  end

  # Close the child if it isn't yet closed.
  #
  # def close_child
  #   @down.w.close # if @down.can_write?
  # end

  # Tries calling the work job in the child process or parent process.
  #
  def try_indexing name
    begin
      pod = Pod.all { |pods| pods.where(:name => name) }.first
      Search.instance.replace pod
      STDOUT.puts "Reindexing #{name} in MASTER successful."
    rescue StandardError => e
      # Catch any error and reraise as a "could not run" error.
      #
      STDOUT.puts "Reindexing #{name} in MASTER failed."
      raise CouldNotRunError.new
    end
  end

end