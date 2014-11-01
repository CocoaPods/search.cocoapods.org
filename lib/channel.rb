require 'cod'
require 'hashie/mash'

# This Channel connects the web worker processes with
# the search engine process.
#
class Channel
  
  def self.instance
    @channel ||= new
  end
  
  def start_with_this_many_children amount
    # For talking to the search index process.
    @amount_of_children = amount
    @to_engines = amount.times.inject({}) do |engines, i|
      engines.tap { |e| e[i] = Cod.pipe }
    end
    @from_engines = amount.times.inject({}) do |engines, i|
      engines.tap { |e| e[i] = Cod.pipe }
    end
    start_search_engine_process
  end
  
  def child_choose_channel number
    @channel_number = number
    @to_engine = @to_engines[number]
    @from_engine = @from_engines[number]
    STDOUT.puts "Child [#{Process.pid}] chose channel #{number} using to: #{@to_engine} and from: #{@from_engine}."
  end
  
  def setup_loop
    # Set up clean exit.
    #
    Signal.trap('INT') do
      STDOUT.puts "Search Engine Process going down."
      exit
    end
    
    # Load the DB.
    #
    require File.expand_path '../database', __FILE__
    
    # Index the DB in the SE process.
    #
    STDOUT.puts "Caching pods in INDEX PROCESS."
    Pods.instance.cache_all
    STDOUT.puts "Finished caching pods in INDEX PROCESS."
  end

  # This runs a process/thread that listens to child processes.
  #
  def start_search_engine_process
    @search_engine_process_pid = fork do
      begin
        setup_loop
      
        not_loaded_yet = true
        pods_to_index = Pods.instance.each
        
        STDOUT.puts "SE process will select on #{@to_engines}."
    
        STDOUT.puts "[#{Time.now}] Start indexing."
        loop do
          # Wait for input from the child for a sub-seconds.
          #
          received = Cod.select 0.05, @to_engines
          process_channels received if received
        
          # Index a few pods at a time until all are indexed.
          #
          # TODO Move elsewhere.
          #
          if not_loaded_yet
            begin
              3.times do
                pod = pods_to_index.next
                STDOUT.print ?.
                Search.instance.replace pod
              end
            rescue StopIteration
              STDOUT.puts "[#{Time.now}] Indexing finished."
              not_loaded_yet = false
            end
          end

          # Fails hard on an error.
          #
        end
      rescue StandardError => e
        STDOUT.puts e.message
      end
    end
    
    Signal.trap('INT') do
      Process.kill('INT', @search_engine_process_pid)
      Process.wait
    end
  end
  
  def process_channels received
    @to_engines.each do |nr, channel|
      if received.has_key? nr
        # STDOUT.puts "Received on #{nr} #{channel}."
        process_channel channel
      end
    end
  end
  
  def process_channel channel
    action, parameters, worker = channel.get
    # STDOUT.puts "Received #{action} with #{parameters} with return address #{worker}."
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

  # Write the search engine process,
  # expecting an answer.
  #
  def call action, message
    # STDOUT.puts "Child [#{Process.pid}] calls SE process with #{action}: #{message}."
    @to_engine.put [action, message, @from_engine]
    @from_engine.get
  end
  
  # Write the search engine process,
  # not expecting an answer.
  #
  def notify action, message
    # STDOUT.puts "Child [#{Process.pid}] notifies SE process with #{action}: #{message}."
    @to_engine.put [action, message, nil]
  end

  # Try indexing a new pod.
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