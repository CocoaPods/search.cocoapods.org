ENV['RACK_ENV'] ||= 'test'

require File.expand_path '../../lib/cocoapods.org', __FILE__

# Tell CocoaPods where the specs are found.
#
ENV['COCOAPODS_SPECS_PATH'] = './spec/data'

Picky::Loader.load_application

# Silence Picky.
#
Picky.logger = Picky::Loggers::Silent.new

def categories_of results
  results.allocations.map do |allocation|
    allocation[3].map { |combination| combination[0] }
  end
end

def ok &block
  should 'be correct', &block
end

# Make LibComponentLogging shut up.
#
Object.send :remove_const, :Config
Config = RbConfig

# Load and prepare everything for the spec(s).
#
Picky::Indexes.index
Picky::Indexes.load
CocoapodSearch.prepare # Needed to load the data for the rendered search results.