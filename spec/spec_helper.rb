# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require_relative 'spec_helper_without_db'
require_relative 'db_seed'

# Run DB tests in a transaction.
#
class Bacon::Context
  alias_method :run_requirement_before_sequel, :run_requirement
  def run_requirement(description, spec)
    Domain.transaction do
      run_requirement_before_sequel(description, spec)
    end
  end
end