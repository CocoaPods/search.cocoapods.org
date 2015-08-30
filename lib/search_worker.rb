require_relative 'stats_sender'

class SearchWorker
  
  attr_reader :stats
  
  def setup
    setup_stats
    
    # TODO Require gems for the search worker only here.
    
    setup_clean_exit

    # Load the DB.
    #
    require File.expand_path '../database', __FILE__

    cache_all_pods

    setup_rarely
    setup_every_so_often
    setup_indexing_all_pods
  end

  def process(action, parameters)
    case action
    when :picky_search
      stats.add_one_query
      Search.instance.picky_search(*parameters)
    when :search
      stats.add_one_query
      Search.instance.search(*parameters, indexing_progress)
    when :search_facets
      stats.add_one_query
      Search.instance.search_facets parameters
    when :index_facets
      stats.add_one_query
      Search.instance.index_facets parameters
    when :split
      stats.add_one_query
      Search.instance.split parameters
    when :reindex
      $stdout.puts "Reindexing #{parameters} in INDEX PROCESS."
      Search.instance.reindex parameters
    else
      $stderr.puts "[Warning] Search worker could not process action #{action} with #{parameters}."
    end
  end
  
  def post_process
    # Initially index a few pods at a time until all are indexed.
    #
    index_some_pods if @not_loaded_yet

    # Periodically send stats data.
    #
    if every_so_often
      $stdout.puts
      $stdout.puts `ps auxm | grep unicorn`
      $stdout.puts
      stats.send_to_status_page
      garbage_collect
    end

    # Periodically index pods to update the metrics in memory.
    #
    setup_indexing_all_pods if rarely
  end

  private

  def garbage_collect
    GC.start
  end
  
  def indexing_progress
    (Search.instance.count.to_f / Pods.instance.count).round(2)
  end

  def index_some_pods
    2.times do
      pod = @pods_to_index.next
      Search.instance.reindex pod.name
    end
  rescue StopIteration
    $stdout.puts "[#{Time.now}] Indexing finished."
    require 'objspace'
    $stdout.puts "[#{Time.now}] Optimizing index memory usage: #{ObjectSpace.memsize_of_all(Array)}."
    optimize_memory
    $stdout.puts "[#{Time.now}] Optimized index memory usage: #{ObjectSpace.memsize_of_all(Array)}."
    @not_loaded_yet = false
  end
  
  # Tells Picky to try recovering some memory.
  #
  # Note: If it takes too long, split up into smaller units.
  #
  def optimize_memory
    Picky::Indexes.optimize_memory
    GC.start
  end

  # Setup the stats counter hash.
  #
  def setup_stats
    @stats = StatsSender.start # Starts a new channel.
  end

  def setup_every_so_often
    @every_so_often = 0
  end
  # Returns roughly every half minute.
  #
  def every_so_often
    @every_so_often += 1
    if @every_so_often % 300 == 0
      @every_so_often = 0
      true
    end
  end

  def setup_rarely
    @rarely = 0
  end
  # Returns true roughly every 40 minutes.
  #
  def rarely
    @rarely += 1
    if @rarely % 24_000 == 0
      @rarely = 0
      true
    end
  end

  def setup_indexing_all_pods
    unless @not_loaded_yet
      @not_loaded_yet = true
      @pods_to_index = Pods.instance.each
      $stdout.puts "[#{Time.now}] Start indexing."
    end
  end

  def setup_clean_exit
    # Set up clean exit.
    #
    # TODO Close pipes.
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
end
