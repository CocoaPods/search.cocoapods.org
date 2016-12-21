# frozen_string_literal: true
# Load the DB after forking.
#
load File.expand_path '../database/db.rb', __FILE__
load File.expand_path '../database/domain.rb', __FILE__
