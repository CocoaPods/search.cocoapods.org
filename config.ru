if ENV['TRACE_RUBY_OBJECT_ALLOCATION']
  require 'objspace'
  ObjectSpace.trace_object_allocations_start
end

require File.expand_path '../app', __FILE__

CocoapodSearch.prepare

GC.start full_mark: true, immediate_sweep: true

run CocoapodSearch