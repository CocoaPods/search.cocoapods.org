CocoapodSearch.helpers do

  def js path
    "<script src='/javascripts/#{path}.js' type='text/javascript'></script>"
  end
  
  def analytics
<<-ANALYTICS
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-29866548-1']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
ANALYTICS
  end
  
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