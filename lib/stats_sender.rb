require 'rest'

class StatsSender
  API_KEY     = ENV['STATUSPAGE_API_KEY']
  QUERIES_URL = ENV['STATUSPAGE_QUERIES_URL']
  MEMORY_URL  = ENV['STATUSPAGE_MEMORY_URL']

  class << self
    
    attr_reader :per_minute_stats
    
    # Start the sender.
    #
    def start
      @per_minute_stats = Hash.new { 0 }
      @channel = Channel.instance(:stats)
      @channel.start children: 1, worker: self
      @channel.choose_channel(0)
      self
    end
  
    # Send the stats to the status page,
    # if there are any stats.
    #
    # It also sends the current PID (usually the search engine
    # PID).
    #
    def send_to_status_page
      time, count = remove_oldest_count_from_stats
      notify(:send, [Process.pid, time.to_i.to_s, count]) if time
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
  
    # Use this method to communicate with it.
    #
    def notify action, message
      @channel.notify(:send, message)
    end
  
    # Add a single query.
    #
    def add_one_query
      per_minute_stats[current_time_bucket] += 1
    end
  
    # Returns the current minute we are writing to.
    #
    def current_time_bucket
      Time.at(Time.now.to_i / 60 * 60)
    end
    
  end
  
  # This method is called once in the child process.
  #
  def setup
    @memory_reporter = -> (search_engine_process_pid) {
      # Return memory usage.
      if Gem.platforms.last.os == 'darwin'
        # OSX
        `ps -o rss= -p #{search_engine_process_pid}`.to_f / 1024.0 # We only send MBs.
      else
        # Heroku (Linux)
        `pmap -x #{search_engine_process_pid} | tail -1 | awk '{print $3}'`.to_i / 1024.0 # We only send MBs.
      end
    }
    Signal.trap('INT') do
      $stdout.puts "[#{Process.pid}] Stats Sender process going down."
      exit
    end
  end
  
  # This method is called each time the stats sender is pinged with data.
  #
  # First parameter is ignored, as it is always :send.
  #
  def process _, message
    search_engine_process_pid, timestamp, count = message
    
    # Send query stats.
    send(QUERIES_URL, timestamp, count)
    
    # Send memory stats.
    send(MEMORY_URL,  timestamp, @memory_reporter.call(search_engine_process_pid))
  end
  
  # Sends data at a time to a (statuspage) URL.
  #
  def send(url, timestamp, amount)
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "OAuth #{API_KEY}",
    }
    if url
      begin
        data = {
          data: {
            timestamp: timestamp,
            value: amount,
          },
        }
        REST.post(url, data.to_json, headers) do |http|
          http.open_timeout = 5
          http.read_timeout = 5
        end
      rescue REST::Error => e
        $stderr.puts "[Warning] Timeout when sending stats with #{data}: #{e.message}."
      end
    end
  rescue StandardError => e
    $stderr.puts "[Warning] #{e.inspect}: #{e.backtrace}"
  end
  
  # Called once.
  # No, Mr StatsSender, I expect you to die.
  def die
    exit
  end
end
