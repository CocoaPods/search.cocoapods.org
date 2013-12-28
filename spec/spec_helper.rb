ENV['PICKY_ENV'] = 'test'

require File.expand_path '../../lib/cocoapods.org', __FILE__

require 'rspec' 

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

# Make LibComponentLogging shut up.
#
Object.send :remove_const, :Config
Config = RbConfig