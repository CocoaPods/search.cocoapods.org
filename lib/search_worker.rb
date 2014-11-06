class SearchWorker
  def setup
    setup_clean_exit

    # Load the DB.
    #
    require File.expand_path '../database', __FILE__

    cache_all_pods

    setup_every_so_often
    setup_indexing_all_pods

    $stdout.puts "[#{Time.now}] Start indexing."
  end

  def process(action, parameters)
    case action
    when :search
      Search.instance.search *parameters
    when :search_facets
      Search.instance.search_facets parameters
    when :index_facets
      Search.instance.index_facets parameters
    when :split
      Search.instance.split parameters
    when :reindex
      # The parameters are just a pod name.
      #
      # TODO: Move to Search.
      #
      $stdout.puts "Reindexing #{parameters} in INDEX PROCESS."
      try_indexing parameters
    end
  end

  def post_process
    # Initially index a few pods at a time until all are indexed.
    #
    if @not_loaded_yet
      begin
        3.times do
          pod = @pods_to_index.next
          STDOUT.print '.'
          Search.instance.replace pod
        end
      rescue StopIteration
        $stdout.puts "[#{Time.now}] Indexing finished."
        @not_loaded_yet = false
      end
    end
    
    # Periodically index pods to update the metrics in memory.
    #
    setup_indexing_all_pods if every_so_often
  end

  private
  
  def setup_every_so_often
    @looped = 0
  end
  
  # Returns true very rarely.
  #
  def every_so_often
    @looped += 1
    if @looped % 50000 == 0
      @looped = 0
      true
    end
  end
  
  def setup_indexing_all_pods
    @not_loaded_yet = true
    @pods_to_index = Pods.instance.each
  end
  
  def setup_clean_exit
    # Set up clean exit.
    #
    Signal.trap('INT') do
      $stdout.puts "[#{Process.pid}] Search Engine process going down."
      exit
    end
  end
  
  def cache_all_pods
    $stdout.puts 'Caching pods in INDEX PROCESS.'
    Pods.instance.cache_all
    $stdout.puts 'Finished caching pods in INDEX PROCESS.'
  end

  # Try indexing a new pod.
  #
  def try_indexing(name)
    pod = Pod.all { |pods| pods.where(name: name) }.first
    Search.instance.replace pod # TODO Also replace the view.
    $stdout.puts "Reindexing #{name} in INDEX PROCESS successful."
  rescue PG::UnableToSend
    STDOUT.puts "PG::UnableToSend raised! Reconnecting to database."
    load 'lib/database.rb'
    retry
  rescue StandardError => e
    # Catch any error and reraise as a "could not run" error.
    #
    $stderr.puts "Reindexing #{name} in INDEX PROCESS failed."
  end
end
