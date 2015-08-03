ENV['RACK_ENV'] = 'test'

require_relative 'db_seed'
require_relative 'spec_helper_without_db'