# Contains helpers for the API.
#
CocoapodSearch.helpers do
  
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