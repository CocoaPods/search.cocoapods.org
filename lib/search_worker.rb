class SearchWorker
  def setup
    # Set up clean exit.
    #
    Signal.trap('INT') do
      $stdout.puts "[#{Process.pid}] Search Engine process going down."
      exit
    end

    # Load the DB.
    #
    require File.expand_path '../database', __FILE__

    # Index the DB in the SE process.
    #
    $stdout.puts 'Caching pods in INDEX PROCESS.'
    Pods.instance.cache_all
    $stdout.puts 'Finished caching pods in INDEX PROCESS.'

    @not_loaded_yet = true
    @pods_to_index = Pods.instance.each

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
    # Index a few pods at a time until all are indexed.
    #
    if @not_loaded_yet
      begin
        3.times do
          pod = @pods_to_index.next
          $stdout.print '.'
          Search.instance.replace pod
        end
      rescue StopIteration
        $stdout.puts "[#{Time.now}] Indexing finished."
        @not_loaded_yet = false
      end
    end
  end

  private

  # Try indexing a new pod.
  #
  def try_indexing(name)
    pod = Pod.all { |pods| pods.where(name: name) }.first
    Search.instance.replace pod
    $stdout.puts "Reindexing #{name} in INDEX PROCESS successful."
  rescue StandardError => e
    # Catch any error and reraise as a "could not run" error.
    #
    $stderr.puts "Reindexing #{name} in INDEX PROCESS failed."
  end
end
