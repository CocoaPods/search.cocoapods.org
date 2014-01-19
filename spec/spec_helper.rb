ENV['PICKY_ENV'] = 'test'

require File.expand_path '../../lib/cocoapods.org', __FILE__

# require 'pathname'
# ROOT = Pathname.new File.expand_path('../../', __FILE__)
# $:.unshift((ROOT + 'spec').to_s)

require 'bundler/setup'
require 'bacon'
require 'mocha-on-bacon'
require 'pretty_bacon'

# Tell CocoaPods where the specs are found.
#
ENV['COCOAPODS_SPECS_PATH'] = './spec/data'

Picky::Loader.load_application

# Silence Picky.
#
Picky.logger = Picky::Loggers::Silent.new

# Make Core shut up.
#
module Pod::CoreUI
  def self.puts(*)
  end
  def self.warn(*)
  end
end

def categories_of results
  results.allocations.map do |allocation|
    allocation[3].map { |combination| combination[0] }
  end
end

def correct &block
  should 'be correct', &block
end

# Make LibComponentLogging shut up.
#
Object.send :remove_const, :Config
Config = RbConfig

# Bacon.
#
Bacon.summary_on_exit

# Load and prepare everything for the spec(s).
#
Picky::Indexes.index
Picky::Indexes.load
CocoapodSearch.prepare # Needed to load the data for the rendered search results.