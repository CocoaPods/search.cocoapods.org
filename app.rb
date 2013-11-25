require 'sinatra/base'
require 'i18n'
require 'picky'
require 'picky-client'
require 'haml'
require 'json'
require 'cocoapods-core'

# Loads the helper class for extracting the searched platform.
#
require File.expand_path '../lib/platform', __FILE__

# Extend Pod::Specification with the capability of ignoring bad specs.
#
require File.expand_path '../lib/pod/specification', __FILE__

# Extend Pod::Specification::Set with a few needed methods for indexing.
#
require File.expand_path '../lib/pod/specification/set', __FILE__

# Load a view proxy for dealing with "rendering".
#
require File.expand_path '../lib/pod/view', __FILE__

# Load pods data container.
#
require File.expand_path '../lib/pods', __FILE__

# Load search interface and index.
#
require File.expand_path '../lib/search', __FILE__

# This app shows how to integrate the Picky server directly
# inside a web app. However, if you really need performance
# and easy caching this is not recommended.
#
class CocoapodSearch < Sinatra::Application
  
  # Data container and search.
  #
  pods = Pods.new Pathname.new ENV['COCOAPODS_SPECS_PATH'] || './tmp/specs'
  search = Search.new pods
  
  self.class.send :define_method, :prepare do |force = false|
    pods.prepare force
    search.reindex
  end
  
  set :logging,       false
  set :static,        true
  set :public_folder, File.dirname(__FILE__)
  set :views,         File.expand_path('../views', __FILE__)

  # The old search page.
  #
  get '/old' do
    @query = params[:q]
    @platform = Platform.extract_from @query
    
    haml :index, :layout => :search
  end

  # Root, the search page.
  #
  get '/' do
    redirect "http://beta.cocoapods.org?q=#{params[:q]}", 'Deprecating current CocoaPods.org'
    
    @query = params[:q]
    @platform = Platform.extract_from @query
    
    haml :index, :layout => :search
  end

  # Renders the results into the json.
  #
  # You get the results from the (local) picky server and then
  # populate the result hash with rendered models.
  #
  get '/search' do
    results = search.interface.search params[:query], params[:ids] || 20, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    results.populate_with Pod::View do |pod|
      pod.render
    end
    Yajl::Encoder.encode results
  end
  
  # An action for beta.cocoapods.org until search.cocoapods.org goes live.
  #
  get '/search.json' do
    response["Access-Control-Allow-Origin"] = "*"
    
    results = search.interface.search params[:query], params[:ids] || 20, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    results.populate_with Pod::View do |pod|
      pod.to_json
    end
    Yajl::Encoder.encode results
  end
  
  # An action for beta.cocoapods.org until search.cocoapods.org goes live.
  #
  # Returns a json with helpful content.
  #
  get '/no_results.json' do
    response["Access-Control-Allow-Origin"] = "*"
    
    query = params[:query]
    
    suggestions = {
      tag: search.index.facets(:tags)
    }
    
    if query
      split = search.splitter.split query
      suggestions[:split] = split if split
    end
    
    Yajl::Encoder.encode suggestions
  end
  
  # Note: Prototyping code.
  #
  get '/pod/:name' do
    pod = pods.specs[params[:name]]
    if pod
      @infos = pod.to_hash
      name = @infos['name']
      authors = @infos['authors']
      
      # Search for authors' other pods.
      #
      @authors = {}
      authors = if authors.respond_to? :keys
        authors.keys
      else
        [authors]
      end
      authors.each do |name|
        names = name.split
        results = search.interface.search names.map { |name| "author:#{name}" }.join(' ')
        @authors[name] = results.ids
      end
      
      # Get topic from pod and search for that topic.
      #
      @tags = {}
      tags = Pod::View.content[name].tags
      tags.each do |name|
        names = name.split
        results = search.interface.search names.map { |name| "tag:#{name}" }.join(' ')
        @tags[name] = results.ids
      end
      
      haml :pod, :layout => :search
    else
      status(404)
      body("Pod not found.")
    end
  end

  # Install get and post hooks.
  #
  [:get, :post].each do |type|
    send type, "/post-receive-hook/#{ENV['HOOK_PATH']}" do
      begin
        self.class.prepare true

        status 200
        body "REINDEXED"
      rescue StandardError => e
        status 500
        body e.message
      end
    end
  end
  
  # API.
  #
  get '/api/v1/pod/:name.json' do
    pod = pods.specs[params[:name]]
    pod && pod.to_hash.to_json || status(404) && body("Pod not found.")
  end

  # Temporary for CocoaDocs till we separate out API & html 
  
  get '/api/v1.5/pods/search' do
    results = search.interface.search params[:query], params[:ids] || 20, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    
    simple_data = []
    results.populate_with Pod::View do |pod|
      simple_data << pod.render_short_json
    end
    
    response["Access-Control-Allow-Origin"] = "*"
    
    Yajl::Encoder.encode simple_data
  end

  require File.expand_path('../helpers', __FILE__)

end
