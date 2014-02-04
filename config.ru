if ENV['TRACE_RUBY_OBJECT_ALLOCATION']
  require 'objspace'
  ObjectSpace.trace_object_allocations_start
end

require File.expand_path '../app', __FILE__

# On startup load the indexes, else create them.
#
begin
  CocoapodSearch.load_indexes
rescue
  CocoapodSearch.prepare
end

run CocoapodSearch