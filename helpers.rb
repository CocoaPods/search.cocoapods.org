CocoapodSearch.helpers do
  
  # Returns a Picky style search result (including how results were found etc.)
  #
  # More info here:
  # TODO Result JSON.
  #
  def picky_result search, params, &rendering
    results = search.interface.search params[:query], params[:ids] || 20, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    
    results.populate_with Pod::View, &rendering
    
    Yajl::Encoder.encode results
  end
  
  # Returns a list style search result – just a list of results (in your rendered format).
  #
  def flat_result search, params, &rendering
    results = search.interface.search params[:query], params[:ids] || 10000, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    
    flat_results = results.ids.map do |id|
      yield Pod::View.content[id]
    end
    
    Yajl::Encoder.encode flat_results
  end
  
  # Allow all origins.
  #
  def cors_allow_all
    response["Access-Control-Allow-Origin"] = "*"
  end

end