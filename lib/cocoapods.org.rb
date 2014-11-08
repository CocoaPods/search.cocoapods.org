Bundler.require(*[:default, ENV['RACK_ENV'].to_sym].compact)

# Loads the helper class for extracting the searched platform.
#
require File.expand_path '../platform', __FILE__

# Load pods data container.
#
require File.expand_path '../pods', __FILE__

# Load search interface and index.
#
require File.expand_path '../search', __FILE__

# Load search engine process.
#
require File.expand_path '../search_worker', __FILE__

# Load analytics process.
#
require File.expand_path '../analytics_worker', __FILE__

# Load web worker - worker process communication.
#
require File.expand_path '../channel', __FILE__
