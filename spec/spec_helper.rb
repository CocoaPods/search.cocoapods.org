# Load DB.
#
if ENV['LOAD_TEST_DB']
  `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d trunk_cocoapods_org_test spec/trunk.dump`
end

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../lib/cocoapods.org', __FILE__
require File.expand_path '../../lib/database', __FILE__

# Tell CocoaPods where the specs are found.
#
ENV['COCOAPODS_SPECS_PATH'] = './spec/data'

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
Object.send :remove_const, :Config
Config = RbConfig

# Load and prepare everything for the spec(s).
#
Pods.instance.cache_all
every = 100
puts "Indexing for a bit (Every . is #{every} pods). If it takes more than 20 seconds, you need a new machine ;)"
Search.instance.reindex every do
  print '.'
end
puts
