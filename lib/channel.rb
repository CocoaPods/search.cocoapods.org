require 'cod'
require 'hashie/mash'

# This is an interface that provides the user of
# Picky with the possibility to change parameters
# while the Application is running.
#
class Channel
  
  def self.instance
    @channel ||= new
  end

  def initialize
    @to_engine   = Cod.pipe # For talking to the search index process.
    @from_engine = Cod.pipe # For talking to a worker process.
    start_search_engine_process
  end

  # This runs a process/thread that listens to child processes.
  #
  def start_search_engine_process
    fork do
      # Load the DB.
      #
      require File.expand_path '../database', __FILE__
      
      # Index the DB in the SE process.
      #
      STDOUT.puts "Caching pods in INDEX PROCESS."
      Pods.instance.cache_all
      STDOUT.puts "Finished caching pods in INDEX PROCESS."
    
      not_loaded_yet = true
      pods_to_index = Pods.instance.each
    
      loop do
        # Wait for input from the child.
        #
        received = Cod.select(0.2, @to_engine)
        if received
          action, parameters, worker = received.get
          response = case action
            when 'search'
              Search.instance.search *parameters
            when 'search_facets'
              Search.instance.search_facets parameters
            when 'index_facets'
              Search.instance.index_facets parameters
            when 'split'
              Search.instance.split parameters
            when 'reindex'
              # The parameters are just a pod name.
              #
              # TODO Move to Search.
              #
              STDOUT.puts "Reindexing #{parameters} in INDEX PROCESS."
              try_indexing parameters
          end
          worker.put response if worker
        end
        
        # Index a few pods.
        #
        if not_loaded_yet
          begin
            10.times do
              pod = pods_to_index.next
              # STDOUT.puts "Indexing #{pod.name}."
              STDOUT.print ?.
              Search.instance.replace pod
            end
          rescue StopIteration
            not_loaded_yet = false
          end
        end

        # Fails hard on an error.
        #
      end
    end
  rescue StandardError => e
    puts e.message
  end

  # Write the search engine process,
  # expecting an answer.
  #
  def call action, message
    @to_engine.put [action, message, @from_engine]
    @from_engine.get
  end
  
  # Write the search engine process,
  # not expecting an answer.
  #
  def notify action, message
    @to_engine.put [action, message, nil]
  end

  # Tries calling the work job in the child process or parent process.
  #
  def try_indexing name
    begin
      pod = Pod.all { |pods| pods.where(:name => name) }.first
      Search.instance.replace pod
      STDOUT.puts "Reindexing #{name} in INDEX PROCESS successful."
    rescue StandardError => e
      # Catch any error and reraise as a "could not run" error.
      #
      STDERR.puts "Reindexing #{name} in INDEX PROCESS failed."
    end
  end

end