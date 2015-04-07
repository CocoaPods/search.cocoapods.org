require 'rest'

class StatsSender
  API_KEY     = ENV['STATUSPAGE_API_KEY']
  QUERIES_URL = ENV['STATUSPAGE_QUERIES_URL']
  MEMORY_URL  = ENV['STATUSPAGE_MEMORY_URL']

  def self.start
    @channel = Channel.instance(:stats)
    @channel.start children: 1, worker: self
    @channel.choose_channel(0)
    self
  end
  
  # Use this method to communicate with it.
  #
  def self.notify action, message
    @channel.notify(:send, message)
  end
  
  def setup
    @memory_reporter = -> {
      `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.
        split.
        last.
        to_i * 1024
    }
    Signal.trap('INT') do
      $stdout.puts "[#{Process.pid}] Stats Sender process going down."
      exit
    end
  end
  
  def process _, message
    time, count = message
    timestamp = time.to_i
    
    # Send query stats.
    send(QUERIES_URL, timestamp, count)
    
    # Send memory stats.
    send(MEMORY_URL,  timestamp, @memory_reporter.call)
  end
  
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
  
  def die
    exit
  end
end
