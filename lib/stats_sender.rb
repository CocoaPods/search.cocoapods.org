require 'rest'

class StatsSender
  URL = ENV['STATUSPAGE_URL']
  API_KEY = ENV['STATUSPAGE_API_KEY']

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
    Signal.trap('INT') do
      $stdout.puts "[#{Process.pid}] Stats Sender process going down."
      exit
    end
  end
  
  def process _, message
    time, count = message
    send(time, count)
  end
  
  def send(time, count)
    data = {
      data: {
        timestamp: time.to_i,
        value: count,
      },
    }
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "OAuth #{API_KEY}",
    }
    if URL
      begin
        $stdout.puts "[Stats] Sending #{data}."
        REST.post(URL, data.to_json, headers) do |http|
          http.open_timeout = 5
          http.read_timeout = 5
        end
        $stdout.puts "[Stats] Sent #{data}."
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
