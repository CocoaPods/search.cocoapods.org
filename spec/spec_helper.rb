ENV['RACK_ENV'] = 'test'

# Load the database state via Humus.
#
unless ENV['NO_DUMP']
  require File.expand_path('../../../Humus/lib/humus', __FILE__)
  Humus.with_snapshot('b008')
end

# Load the app.
#
require File.expand_path '../../lib/cocoapods.org', __FILE__

# Load the database setup.
#
require File.expand_path '../../lib/database', __FILE__

# Install some controller spec helpers.
#
class Bacon::Context
  def test_controller!(app)
    extend Rack::Test::Methods

    singleton_class.send(:define_method, :app) { app }
    singleton_class.send(:define_method, :response_doc) { Nokogiri::HTML(last_response.body) }
  end

  alias_method :run_requirement_before_sequel, :run_requirement
  def run_requirement(description, spec)
    Domain.transaction do
      run_requirement_before_sequel(description, spec)
    end
  end
end

Picky::Loader.load_application

# Silence Picky.
#
Picky.logger = Picky::Loggers::Verbose.new

# Spec helper methods.
#

def categories_of(results)
  results.allocations.map do |allocation|
    allocation[3].map { |combination| combination[0] }
  end
end

def ok(&block)
  should 'be correct', &block
end

# Make LibComponentLogging shut up.
#
Object.send :remove_const, :Config if defined?(::Config)
Config = RbConfig

def memory_profiled enabled = true, &block
  if enabled
    require 'memory_profiler'
    report = MemoryProfiler.report &block
    report.pretty_print
  else
    yield
  end
end

# Load and prepare everything for the spec(s).
#
puts "Memory used before indexing (kB): #{`ps -o rss -p #{Process.pid}`}"
puts "Caching all pods."
memory_profiled ENV['PROFILE_MEMORY'] do
  Pods.instance.cache_all
  every = 5
  amount = 200 # We only use 200 pods.
  puts "Indexing #{amount} pods (Every . is #{every} pods)."
  Search.instance.reindex_all every, amount do
    print '.'
  end
end
puts
puts "Memory used after indexing (kB): #{`ps -o rss -p #{Process.pid}`}"