ENV['PICKY_ENV'] = 'test'

require 'picky'
require 'rspec'

ENV['COCOAPODS_SPECS_PATH'] = 'spec/data'

Picky::Loader.load_application