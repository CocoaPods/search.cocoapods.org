require 'rest'

class StatsSender
  URL = ENV['STATUSPAGE_URL']
  API_KEY = ENV['STATUSPAGE_API_KEY']

  def self.cleanup
    init
    if pid = @current_pids.shift
      Process.waitpid(pid, Process::WNOHANG)
    end
  end

  def self.send(time, count)
    cleanup
    
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
    @current_pids << fork do
      REST.post(URL, data.to_json, headers) do |http|
        http.open_timeout = 2
        http.read_timeout = 2
      end
    end
  end
  
  def self.init
    @current_pids ||= []
  end
end
