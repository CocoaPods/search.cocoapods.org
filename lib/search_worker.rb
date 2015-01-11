require_relative 'stats_sender'

class SearchWorker
  def setup
    setup_clean_exit

    # Load the DB.
    #
    require File.expand_path '../database', __FILE__

    cache_all_pods

    setup_stats
    setup_rarely
    setup_every_so_often
    setup_indexing_all_pods
  end

  def process(action, parameters)
    case action
    when :search
      add_one_query_to_stats
      Search.instance.search(*parameters)
    when :search_facets
      add_one_query_to_stats
      Search.instance.search_facets parameters
    when :index_facets
      add_one_query_to_stats
      Search.instance.index_facets parameters
    when :split
      add_one_query_to_stats
      Search.instance.split parameters
    when :reindex
      # The parameters are just a pod name.
      #
      # TODO: Move to Search.
      #
      $stdout.puts "Reindexing #{parameters} in INDEX PROCESS."
      try_indexing parameters
    else
      $stderr.puts "Search worker could not process action #{action} with #{parameters}."
    end
  end

  def post_process
    # Initially index a few pods at a time until all are indexed.
    #
    if @not_loaded_yet
      begin
        2.times do
          pod = @pods_to_index.next
          try_indexing(pod.name)
        end
      rescue StopIteration
        $stdout.puts "[#{Time.now}] Indexing finished."
        @not_loaded_yet = false
      end
    end

    # Periodically send stats data.
    #
    send_stats_to_status_page if every_so_often

    # Periodically index pods to update the metrics in memory.
    #
    setup_indexing_all_pods if rarely
  end

  private

  attr_reader :per_minute_stats

  # Setup the stats counter hash.
  #
  def setup_stats
    @per_minute_stats = Hash.new { 0 }
  end

  # Add a single query.
  #
  def add_one_query_to_stats
    per_minute_stats[current_time_bucket] += 1
  end

  # Returns the current minute we are writing to.
  #
  def current_time_bucket
    Time.at(Time.now.to_i / 60 * 60)
  end

  # Returns either nil or [time, count]
  #
  def remove_oldest_count_from_stats
    # Get the oldest statistic.
    time, count = per_minute_stats.first

    # If the count is not ongoing anymore.
    unless time == current_time_bucket
      # Return the count for a time
      [time, per_minute_stats.delete(time)]
    end
  end

  # Send the stats to the status page,
  # if there are any stats.
  #
  def send_stats_to_status_page
    time, count = remove_oldest_count_from_stats
    StatsSender.send(time, count) if time
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
  # Returns true roughly every 20 minutes.
  #
  def rarely
    @rarely += 1
    if @rarely % 12_000 == 0
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
    Search.instance.replace pod, Pods.instance
    $stdout.print ?✓
  rescue PG::UnableToSend
    $stdout.puts 'PG::UnableToSend raised! Reconnecting to database.'
    load 'lib/database.rb'
    retry
  rescue StandardError
    # Catch any error and reraise as a "could not run" error.
    #
    $stderr.puts "Error: Reindexing #{name} in INDEX PROCESS has failed."
  end
end
