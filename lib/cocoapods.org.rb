require 'sinatra/base'
require 'i18n'
require 'picky'
require 'picky-client'
require 'haml'
require 'json'
require 'cocoapods-core'

# Loads the helper class for extracting the searched platform.
#
require File.expand_path '../platform', __FILE__

# Extend Pod::Specification with the capability of ignoring bad specs.
#
require File.expand_path '../pod/specification', __FILE__

# Wrap Pod::Specification::Set with a few needed methods for indexing.
#
require File.expand_path '../pod/specification/wrapped_set', __FILE__

# Load a view proxy for dealing with "rendering".
#
require File.expand_path '../pod/view', __FILE__

# Load pods data container.
#
require File.expand_path '../pods', __FILE__

# Load search interface and index.
#
require File.expand_path '../search', __FILE__