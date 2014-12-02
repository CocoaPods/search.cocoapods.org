require 'rest'

class StatsSender
  
  URL = ENV['STATUSPAGE_URL']
  API_KEY = ENV['STATUSPAGE_API_KEY']
  
  def self.send time, count
    data = {
      :data => {
        :timestamp => time.to_i,
        :value => count
      }
    }
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "OAuth #{API_KEY}",
    }
    fork do
      REST.post(URL, data.to_json, headers) do |http|
        http.open_timeout = 1
        http.read_timeout = 1
      end
    end
  end
  
end