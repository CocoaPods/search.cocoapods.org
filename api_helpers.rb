# Contains helpers for the API.
#
CocoapodSearch.helpers do
  
  @api_routes = []
  
  def self.store method, path
    @api_routes << path if :get == method
  end
  
  # Return all API routes in their original form.
  #
  def self.api_routes
    @api_routes
  end
  
  # Creates two API endpoints:
  #   1. Comfortable URL-based.
  #   2. HTTP header-based.
  #
  def self.api method, path, &calculation
    store method, convenient_path = "/api/v2.0/#{path}.json"
    
    # Create a convenient browser-accessible endpoint.
    #
    send method, convenient_path do
      cors_allow_all
      
      json instance_eval &calculation
    end
    
    store method, http_path = "/api/#{path}"
    
    # Create a machine/command-line accessible endpoint.
    #
    send method, http_path do
      cors_allow_all
      
      request.accept.each do |accept|
        case accept.params['version']
        when nil
          # Without explicit version it will by default provide the latest version.
          #
          case accept.to_s
          when '*/*'
            halt json instance_eval &calculation
          when 'text/json'
            halt json instance_eval &calculation
          when 'application/json'
            halt json instance_eval &calculation
          end
        when '2'
          case accept.to_s
          when 'application/json'
            halt json instance_eval &calculation
          end
        else
          halt 406
        end
      end
      
      halt 406
    end
  end
  
  # Returns a Picky style search result (including how results were found etc.)
  #
  # More info here: https://github.com/floere/picky/wiki/Results-format-and-structure.
  #
  def picky_result search, params, &rendering
    results = search.interface.search params[:query], params[:ids] || 20, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    
    results.populate_with Pod::View, &rendering
    
    results
  end
  
  # Returns a list style search result – just a list of results (in your rendered format).
  #
  def flat_result search, params, &rendering
    results = search.interface.search params[:query], params[:ids] || 20, params[:offset] || 0
    
    flat_results = results.ids.map do |id|
      rendering.call Pod::View.content[id]
    end
    
    flat_results
  end
  
  # Allow all origins.
  #
  def cors_allow_all
    response["Access-Control-Allow-Origin"] = "*"
  end
  
  # Encode as json.
  #
  def json results
    Yajl::Encoder.encode results
  end

end