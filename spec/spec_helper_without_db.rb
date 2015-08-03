ENV['RACK_ENV'] = 'test'

# Load the app.
#
require File.expand_path '../../lib/cocoapods.org', __FILE__

# Load the database setup.
#
require File.expand_path '../../lib/database', __FILE__

# Install some controller spec helpers.
#
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

# Spec helper methods.
#

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
Object.send :remove_const, :Config if defined?(::Config)
Config = RbConfig