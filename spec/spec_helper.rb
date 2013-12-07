ENV['PICKY_ENV'] = 'test'

require File.expand_path '../../lib/cocoapods.org', __FILE__

require 'rspec' 

ENV['COCOAPODS_SPECS_PATH'] = './spec/data'

Picky::Loader.load_application