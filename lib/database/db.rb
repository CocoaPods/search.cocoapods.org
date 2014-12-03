ENV['RACK_ENV'] ||= 'production'
ENV['DATABASE_URL'] ||=
  "postgres://localhost/trunk_cocoapods_org_#{ENV['RACK_ENV']}"
puts "[#{Process.pid}] Using DB: #{ENV['DATABASE_URL']}."

#
#
uri = DataObjects::URI.parse(ENV['DATABASE_URL'])
options = {}
[:host, :port, :user, :password].each do |key|
  val = uri.send(key)
  options[key] = val if val
end
if socket_dir = ENV['POSTGRES_UNIX_SOCKET']
  App.logger.debug "Using unix socket connection for flounder. (#{socket_dir})"
  options[:host] = socket_dir
end
options[:dbname] = uri.path[1..-1]

DB = Flounder.connect options
