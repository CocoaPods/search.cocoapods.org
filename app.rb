require File.expand_path '../lib/cocoapods.org', __FILE__

# Store the indexes in tmp.
#
Picky.root = 'tmp'

# The Sinatra search server.
#
# Mainly offers two things:
#  * Search API methods.
#  * Index update URL for the Github update hook.
#
class CocoapodSearch < Sinatra::Application
  # Allow a setting whether this app is a child or not.
  #
  class << self
    attr_accessor :child
  end

  # Allow browsers to cache responses for a minute.
  # This helps with backspacing.
  #
  before { expires 60, :public }

  # Data container and search.
  #
  repo = Pods.instance
  search = Search.instance

  set :logging, false

  # search.cocoapods.org API 2.0
  #
  # Follows this convention:
  #
  # /api/<version>/<result collection>.<result structure>.<result item format>.<result format>?<query params>
  #
  # Explanation:
  # * /api This is the API of search.cocoapods.org.
  # * <version> Version 2.0 of the API.
  # * <result collection> What you are searching. Available:
  #   * pods Result items will be pods.
  # * <result structure> How the results are structured. Available:
  #   * flat Results are a flat list of result items without extra information.
  #   * picky https://github.com/floere/picky/wiki/Results-format-and-structure
  # * <result item format> The format of each item in the results. Available:
  #   * hash A hash representing the result item.
  #   * ids Just the id of a result item.
  # * <result format> The data format of the results. Available:
  #   * json
  # * <query params> Options to filter. Available:
  #   * query A Picky style query.
  #   * ids The amount of ids wanted.
  #   * offset The offset in the results.
  #
  # Example:
  #   http://search.cocoapods.org/api/v1/pods.picky.hash.json?query=author:eloy&ids=20&offset=0
  #

  # Machine based API:
  #
  # Example:
  #   curl http://search.cocoapods.org/api/pods?query=test -H "Accept: application/vnd.cocoapods.org+picky.hash.json; version=1"
  #   curl http://search.cocoapods.org/api/pods?query=test -H "Accept: application/vnd.cocoapods.org+picky.ids.json; version=1"
  #   curl http://search.cocoapods.org/api/pods?query=test -H "Accept: application/vnd.cocoapods.org+flat.hash.json; version=1"
  #   curl http://search.cocoapods.org/api/pods?query=test -H "Accept: application/vnd.cocoapods.org+flat.ids.json; version=1"
  #

  # Helpers used by the API.
  #
  require File.expand_path('../api_helpers', __FILE__)

  # Default endpoint returns the latest picky hash version.
  #
  api nil, :flat, :ids, :json, accept: ['*/*', 'text/json', 'application/json'] do
    CocoapodSearch.track_view request, :'default-flat/ids/json'
    json picky_result(search, repo, params) { |item| item.name }
  end

  # Returns a Picky style result with entries rendered as a hash.
  #
  api 1, :picky, :hash, :json, accept: ['application/vnd.cocoapods.org+picky.hash.json'] do
    CocoapodSearch.track_view request, :'picky/hash/json'
    json picky_result(search, repo, params) { |item| item.to_h }
  end

  # Returns a Picky style result with just ids as entries.
  #
  api 1, :picky, :ids, :json, accept: ['application/vnd.cocoapods.org+picky.ids.json'] do
    CocoapodSearch.track_view request, :'picky/ids/json'
    json picky_result(search, repo, params) { |item| item.name }
  end

  # Returns a flat list of results with entries rendered as a hash.
  #
  api 1, :flat, :hash, :json, accept: ['application/vnd.cocoapods.org+flat.hash.json'] do
    CocoapodSearch.track_view request, :'flat/hash/json'
    json flat_result(search, repo, params) { |item| item.to_h }
  end

  # Returns a flat list of ids.
  #
  api 1, :flat, :ids, :json, accept: ['application/vnd.cocoapods.org+flat.ids.json'] do
    CocoapodSearch.track_view request, :'flat/ids/json'
    json flat_result(search, repo, params) { |item| item.name }
  end

  # Installs API for calls using Accept.
  #
  install_machine_api

  # Returns a JSON hash with helpful content with "no results" specific to cocoapods.org.
  #
  # TODO: Move this into an API?
  #
  get '/no_results.json' do
    response['Access-Control-Allow-Origin'] = '*'

    query = params[:query]

    suggestions = {
      tag: search.index_facets(:tags),
    }

    if query
      split = search.split query
      results = search.search split.join(' '), 0, 0
      results.extend Picky::Convenience
      suggestions[:split] = [split, results.total]
    end

    Yajl::Encoder.encode suggestions
  end

  # Experimental APIs.
  #
  get '/api/v1/pods.facets.json' do
    normalized_params = params.inject({}) do |result, (param, value)|
      result[param.gsub(/\-/, '_').to_sym] = Integer(value) rescue value
      result
    end
    CocoapodSearch.track_facets request
    body json search.search_facets normalized_params
  end

  # Handles updating pod data.
  #
  [:get, :post].each do |type|
    send type, "/hooks/trunk/#{ENV['HOOK_PATH']}" do
      begin
        data = JSON.parse(params['message'])
        name = data['pod']
        # name = params[:name] # For local testing.

        Channel.instance(:search).notify :reindex, name

        status 200
        body "REINDEXING #{name}"
      rescue StandardError => e
        status 500
        body e.message
      end
    end
  end

  # Tracking convenience methods.
  #
  def self.track_search(query, total)
    analytics.notify :event, [:pods, :search, query, total]
  end
  def self.track_facets(request)
    analytics.notify :event, [:pods, :facets, request.query_string]
  end
  def self.track_view(request, title)
    analytics.notify :page_view, [title, request.path]
  end
  def self.analytics
    @analytics ||= Channel.instance(:analytics)
  end
end
