require File.expand_path '../lib/cocoapods.org', __FILE__

# The Sinatra search server.
#
# Mainly offers two things:
#  * Search API methods.
#  * Index update URL for the Github update hook.
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
  #   http://search.cocoapods.org/api/v2.0/pods.picky.hash.json?query=author:eloy&ids=20&offset=0
  #
  
  # Helpers used by the API.
  #
  require File.expand_path('../api_helpers', __FILE__)
  
  # Returns a Picky style JSON result with entries rendered as a JSON hash.
  #
  get '/api/v2.0/pods.picky.hash.json' do
    cors_allow_all
    
    json picky_result search, params, &:to_hash
  end
  
  # Returns a Picky style JSON result with just ids as entries.
  #
  get '/api/v2.0/pods.picky.ids.json' do
    cors_allow_all
    
    json picky_result search, params, &:id
  end
  
  # Returns a flat list of results with entries rendered as a JSON hash.
  #
  get '/api/v2.0/pods.flat.hash.json' do
    cors_allow_all
    
    json flat_result search, params, &:to_hash
  end
  
  # Returns a flat list of ids in the JSON format.
  #
  get '/api/v2.0/pods.flat.ids.json' do
    cors_allow_all
    
    json flat_result search, params, &:id
  end
  
  # OPTIONS information.
  #
  [:picky, :flat].each do |structure|
    [:hash, :ids].each do |item_format|
      options "/api/v2.0/pods.#{structure}.#{item_format}.json" do
        response['Allow'] = 'GET,OPTIONS'
        info = {
          GET: {
            description: "Perform a query and receive a #{structure} JSON result with result items formatted as #{item_format}.",
            parameters: {
              query: {
                type: "string",
                description: "The search query. All Picky special characters are allowed and used.",
                required: true                
              },
              ids: {
                type: "integer",
                description: "How many result ids and items should be returned with the result.",
                required: false,
                default: 20
              },
              offset: {
                type: "integer",
                description: "At what position the query results should start.",
                required: false,
                default: 0
              }
            },
            example: {
              query: "af networking",
              ids: 50,
              offset: 0
            }
          }
        }
        json info
      end
    end
  end
  
  # Temporary for CocoaDocs till we separate out API & html 
  #
  # TODO Remove.
  #
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
  
  # Pod API code.
  #
  # TODO Remove -> Trunk will handle this.
  #
  # Currently only used by @fjcaetano for badge handling.
  #
  get '/api/v1/pod/:name.json' do
    pod = pods.specs[params[:name]]
    pod && pod.to_hash.to_json || status(404) && body("Pod not found.")
  end
  
  # Returns a JSON hash with helpful content with "no results" specific to cocoapods.org.
  #
  # TODO Move this into an API?
  #
  get '/no_results.json' do
    response["Access-Control-Allow-Origin"] = "*"
    
    query = params[:query]
    
    suggestions = {
      tag: search.index.facets(:tags)
    }
    
    if query
      split = search.splitter.split query
      result = search.interface.search split.join(' '), 0, 0
      suggestions[:split] = [split, result.total]
    end
    
    Yajl::Encoder.encode suggestions
  end

  # Get and post hooks for triggering index updates.
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

end
