Bundler.require *[:default, ENV['RACK_ENV']].compact

# Loads the helper class for extracting the searched platform.
#
require File.expand_path '../platform', __FILE__

# Load pods data container.
#
require File.expand_path '../pods', __FILE__

# Load search interface and index.
#
require File.expand_path '../search', __FILE__

# Load worker - search engine process communication.
#
require File.expand_path '../channel', __FILE__