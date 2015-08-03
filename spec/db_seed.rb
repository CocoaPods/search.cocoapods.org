# Load the database state via Humus.
#
unless ENV['NO_DUMP']
  require File.expand_path('../../../Humus/lib/humus', __FILE__)
  Humus.with_snapshot('b008')
end

# With a possible memory profile ... do.
#
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