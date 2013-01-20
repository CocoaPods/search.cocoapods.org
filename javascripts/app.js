var platformRemoverRegexp = /(platform|on\:\w+\s?)+/;
var platformSelect = $(".platform");
      
// Sets the checkbox labels correctly.
//
var selectCheckedPlatform = function() {
  platformSelect.find('label').removeClass('selected');
  platformSelect.find('input:checked + label').addClass('selected');
};
      
// Tracking the search results.
//
var trackAnalytics = function(data, query) {
var total = data.total;
if (total > 0) {
  _gaq.push(['_trackEvent', 'search', 'with results', query, total]);
} else {
  _gaq.push(['_trackEvent', 'search', 'not found', query, 0]);
}
}
      
// TODO Add tap gesture support to the cycle button?
$(window).ready(function() {
  pickyClient = new PickyClient({
    full: '/search',
      
    // The live query does a full query.
    //
    live: '/search',
    liveResults: 20,
    liveRendered: true, // Experimental: Render live results as if they were full ones.
    liveSearchInterval: 60, // Time between keystrokes before it sends the query.

    // Instead of enclosing the search in #picky,
    // in the CocoaPods search we use #search.
    //
    enclosingSelector: '#search',
    resetSelector: 'a.reset-search',
    maxSuggestions: 4,
    moreSelector: '#search .allocations .more',

    // Before a query is inserted into the search field
    // we clean it of any platform terms.
    //
    beforeInsert: function(query) {
      return query.replace(platformRemoverRegexp, '');
    },

    after: function(data, query) {
      $('.clippy').clippy({
        'clippy_path': '/media/clippy.swf'
      });
    },
    // Before Picky sends any data to the server.
    //
    // Adds the platform modifier to it if it isn't there already.
    // Removes it if it is.
    //
    before: function(query, params) {
      // We don't add the platform if it is empty (still saved in history as empty, though).
      //
      if (query == '') { return ''; }
      query = query.replace(platformRemoverRegexp, '');
      var platformModifier = platformSelect.find("input:checked").val();
      if (platformModifier == '') { return query; }
      return platformModifier + ' ' + query;
    },
    // We filter duplicate ids here.
    // (Not in the server as it might be
    // used for APIs etc.)
    //
    // We also track the data for analytics.
    //
    success: function(data, query) {
      trackAnalytics(data, query);
            
      var seen = {};
            
      var allocations = data.allocations;
      allocations.each(function(i, allocation) {
        var ids     = allocation.ids;
        var entries = allocation.entries;
        var remove = [];
              
        ids.each(function(j, id) {
          if (seen[id]) {
            data.total -= 1;
            remove.push(j);
          } else {
            seen[id] = true;
          }
        });
              
        for(var l = remove.length-1; 0 <= l; l--) {
          entries.splice(remove[l], 1);
        }
              
        allocation.entries = entries;
        });
            
      return data;
    },
    // after: function(data, query) {  }, // After Picky has handled the data and updated the view.

    // This is used to generate the correct query strings, localized. E.g. "subject:war".
    // Note: If you don't give these, the field identifier given in the Picky server is used.
    //
    qualifiers: {
      en:{
        dependencies: 'uses',
        platform: 'on'
      }
    },

    // Use this to group the choices (those are used when Picky needs more feedback).
    // If a category is missing, it is appended in a virtual group at the end.
    // Optional. Default is [].
    //
    // We group platform explicitly, so it is always positioned at
    // the start of the explanation of the choices (also, we can
    // simply not show it).
    //
    groups: [['platform']],
          
    // This is used for formatting inside the choice groups.
    //
    // Use %n$s, where n is the position of the category in the key.
    // Optional. Default is {}.
    //
    choices: {
      en: {
        'platform': '', // platform is simply never shown.
              
        'name': 'Called %1$s',
        'author': 'Written by %1$s',
        'summary': 'Having \"%1$s\" in summary',
        'dependencies': 'Using %1$s',
        'author,name': 'Called %2$s, written by %1$s',
        'name,author': 'Called %1$s, written by %2$s',
        'version,name': '%1$s of %2$s',
        'name,dependencies': '%1$s, using %2$s',
        'dependencies,name': '%1$s used by %2$s',
        'author,dependencies': 'Written by %1$s and using %2$s',
        'dependencies,author': 'Using %1$s, written by %2$s',
        'dependencies,version': '%1$s used by version %2$s',
        'version,dependencies': '%2$s used by version %1$s',
        'author,version': 'Version %2$s by %1$s',
        'version,author': 'Version %1$s by %2$s',
        'summary,version': 'Version %2$s with \"%1$s\" in summary',
        'version,summary': 'Version %1$s with \"%2$s\" in summary',
        'summary,name': 'Called %2$s, with \"%1$s\" in summary',
        'name,summary': 'Called %1$s, with \"%2$s\" in summary',
        'summary,author': 'Written by %2$s with \"%1$s\" in summary',
        'author,summary': 'Written by %1$s with \"%2$s\" in summary',
        'summary,dependencies': 'Has \"%1$s\" in summary and uses %2$s',
        'dependencies,summary': 'Has \"%2$s\" in summary and uses %1$s',
        'name,dependencies': 'Called \"%1$s\", using %2$s',
        'dependencies,name': 'Called \"%2$s\", using %1$s'
      }
    },

    // This is used to explain the preceding word in the suggestion text (if it
    // has not yet been defined by the choices above), localized. E.g. "Peter (author)".
    // Optional. Default are the field identifiers from the Picky server.
    //
    explanations: {
      en:{
        name: 'named',
        author: 'written by',
        versions: 'on version',
        dependencies: 'using',
        summary: 'with summary'
        }
      }
    }
  );
        
  // Resend query on platform selection.
  //
  // Note: Also updates the label.
  //
  platformSelect.find('input').bind('change', function(event) {
    pickyClient.resend();
    selectCheckedPlatform();
    $("#pod_search").focus();
  });
        
  // Initially select the right platform.
  //
  selectCheckedPlatform();
        
  // Initially insert the query given in the URL
  // if there is one.
  //
  
  if (window.initial_query != "") {
    pickyClient.insertFromURL(window.initial_query);
  }
});
