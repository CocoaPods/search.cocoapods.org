# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do
  
  before(:all) do
    Picky::Indexes.index
    Picky::Indexes.load
    CocoapodSearch.prepare # Needed to load the data for the rendered search results.
  end

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/search') }
  
  # Testing a count of results.
  #
  it { pods.search('on:ios 1.0.0').total.should == 310 }

  # Testing a specific order of result ids.
  #
  it { pods.search('on:osx ki').ids.should == ["ADNKit", "AFKissXMLRequestOperation", "AZAppearanceKit", "BlocksKit", "ConciseKit", "FormatterKit", "GHKit", "InflectorKit", "JSONKit", "KISSmetrics", "KissXML", "Kiwi", "MacMapKit", "MKNetworkKit", "NoodleKit", "OctoKit", "ParseKit", "PodioKit", "PostageKit", "QuincyKit"] }
  
  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.005 # seconds
  end

  # Similarity on author.
  #
  it { pods.search('on:ios thompsen~').ids.should == ["AFAmazonS3Client", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFKissXMLRequestOperation", "AFNetworking", "AFOAuth1Client", "AFOAuth2Client", "AFUrbanAirshipClient", "AFXAuthClient", "Antenna", "AnyJSON", "CargoBay", "CupertinoYankee", "FormatterKit", "Godzippa", "GroundControl", "InflectorKit", "Orbiter", "SkyLab", "TransformerKit"] }
  
  # Partial version search.
  #
  it { pods.search('on:osx kiwi 1').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0.').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0.0').ids.should == ['Kiwi'] }
  
  # Platform constrained search (platforms are AND-ed).
  #
  it { pods.search('on:osx thompson').ids.should == ["AFAmazonS3Client", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFKissXMLRequestOperation", "AFNetworking", "AFOAuth1Client", "AFOAuth2Client", "AFUrbanAirshipClient", "AFXAuthClient", "AnyJSON", "CargoBay", "CupertinoYankee", "FormatterKit", "Godzippa", "GroundControl", "InflectorKit", "Orbiter", "SkyLab", "TransformerKit", "TTTLocalizedPluralString"] }
  it { pods.search('on:ios thompson').ids.should == ["AFAmazonS3Client", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFKissXMLRequestOperation", "AFNetworking", "AFOAuth1Client", "AFOAuth2Client", "AFUrbanAirshipClient", "AFXAuthClient", "Antenna", "AnyJSON", "CargoBay", "CupertinoYankee", "FormatterKit", "Godzippa", "GroundControl", "InflectorKit", "Orbiter", "SkyLab", "TransformerKit"] }
  it { pods.search('on:osx on:ios thompson').ids.should == ["AFAmazonS3Client", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFKissXMLRequestOperation", "AFNetworking", "AFOAuth1Client", "AFOAuth2Client", "AFUrbanAirshipClient", "AFXAuthClient", "AnyJSON", "CargoBay", "CupertinoYankee", "FormatterKit", "Godzippa", "GroundControl", "InflectorKit", "Orbiter", "SkyLab", "TransformerKit", "TTTLocalizedPluralString"] }
  
  # Category boosting.
  #
  it { pods.search('on:osx k* a').should have_categories(["platform", "name", "author"], ["platform", "name", "name"], ["platform", "author", "summary"], ["platform", "author", "name"], ["platform", "author", "author"], ["platform", "summary", "name"], ["platform", "summary", "author"], ["platform", "author", "dependencies"], ["platform", "name", "dependencies"], ["platform", "dependencies", "summary"], ["platform", "summary", "dependencies"], ["platform", "name", "summary"], ["platform", "summary", "summary"], ["platform", "dependencies", "name"], ["platform", "dependencies", "dependencies"]) }
  it { pods.search('on:osx jsonkit').should have_categories(["platform", "dependencies"], ["platform", "name"]) }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  it { pods.search('platform:osx').total.should == 511 }
  it { pods.search('platform:os').total.should == 0 }
  it { pods.search('platform:o').total.should == 0 }
  
  # Rendering.
  #
  pod_spec = "pod 'Kiwi', '~&gt; 1.0.0'"
  it { pods.search('kiwi').entries.should == ["<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/allending/Kiwi\">Kiwi</a>\n      \n      <span class=\"version\">\n        2.1\n        <span class=\"clippy\">pod 'Kiwi', '~&gt; 2.1'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>A Behavior Driven Development library for iOS and OS X.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Allen Ding')\">Allen Ding</a> and <a href=\"javascript:pickyClient.insert('Luke Redpath')\">Luke Redpath</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/Kiwi/2.1\">Docs</a>\n    <a href=\"https://github.com/allending/Kiwi\">Repo</a>\n  </div>\n</li>\n", "<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/RestKit/RKKiwiMatchers\">RKKiwiMatchers</a>\n      <span class=\"os\">iOS only</span>\n      <span class=\"version\">\n        0.20.0\n        <span class=\"clippy\">pod 'RKKiwiMatchers', '~&gt; 0.20.0'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>Provides a rich set of matchers for use in testing RestKit applications with the Kiwi Behavior Driven Development library.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Blake Watters')\">Blake Watters</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/RKKiwiMatchers/0.20.0\">Docs</a>\n    <a href=\"https://github.com/RestKit/RKKiwiMatchers\">Repo</a>\n  </div>\n</li>\n", "<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/lucasmedeirosleite/ActiveTouch\">ActiveTouch</a>\n      <span class=\"os\">iOS only</span>\n      <span class=\"version\">\n        1.0.4\n        <span class=\"clippy\">pod 'ActiveTouch', '~&gt; 1.0.4'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>ActiveRecord implementation for iOS using TouchDB.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Lucas Medeiros')\">Lucas Medeiros</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/ActiveTouch/1.0.4\">Docs</a>\n    <a href=\"https://github.com/lucasmedeirosleite/ActiveTouch\">Repo</a>\n  </div>\n</li>\n", "<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/AshFurrow/AFImageDownloader\">AFImageDownloader</a>\n      <span class=\"os\">iOS only</span>\n      <span class=\"version\">\n        1.0.0\n        <span class=\"clippy\">pod 'AFImageDownloader', '~&gt; 1.0.0'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>Downloads JPEG images asynchronously and decompresses them on a background thread.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Ash Furrow')\">Ash Furrow</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/AFImageDownloader/1.0.0\">Docs</a>\n    <a href=\"https://github.com/AshFurrow/AFImageDownloader\">Repo</a>\n  </div>\n</li>\n", "<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/gantaa/MockInject\">MockInject</a>\n      <span class=\"os\">iOS only</span>\n      <span class=\"version\">\n        0.1.0\n        <span class=\"clippy\">pod 'MockInject', '~&gt; 0.1.0'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>A library that allows developers to globally mock any ObjectiveC class' initialization method when testing with Kiwi.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Matt Ganski')\">Matt Ganski</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/MockInject/0.1.0\">Docs</a>\n    <a href=\"https://github.com/gantaa/MockInject\">Repo</a>\n  </div>\n</li>\n", "<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/RestKit/RKKiwiMatchers\">RKKiwiMatchers</a>\n      <span class=\"os\">iOS only</span>\n      <span class=\"version\">\n        0.20.0\n        <span class=\"clippy\">pod 'RKKiwiMatchers', '~&gt; 0.20.0'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>Provides a rich set of matchers for use in testing RestKit applications with the Kiwi Behavior Driven Development library.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Blake Watters')\">Blake Watters</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/RKKiwiMatchers/0.20.0\">Docs</a>\n    <a href=\"https://github.com/RestKit/RKKiwiMatchers\">Repo</a>\n  </div>\n</li>\n", "<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/gantaa/MockInject\">MockInject</a>\n      <span class=\"os\">iOS only</span>\n      <span class=\"version\">\n        0.1.0\n        <span class=\"clippy\">pod 'MockInject', '~&gt; 0.1.0'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>A library that allows developers to globally mock any ObjectiveC class' initialization method when testing with Kiwi.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Matt Ganski')\">Matt Ganski</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/MockInject/0.1.0\">Docs</a>\n    <a href=\"https://github.com/gantaa/MockInject\">Repo</a>\n  </div>\n</li>\n", "<li class=\"result\">\n  <div class=\"infos\">\n    <h3>\n      <a href=\"https://github.com/RestKit/RKKiwiMatchers\">RKKiwiMatchers</a>\n      <span class=\"os\">iOS only</span>\n      <span class=\"version\">\n        0.20.0\n        <span class=\"clippy\">pod 'RKKiwiMatchers', '~&gt; 0.20.0'</span>\n      </span>\n    </h3>\n    <p class=\"subspecs\"></p>\n    <p>Provides a rich set of matchers for use in testing RestKit applications with the Kiwi Behavior Driven Development library.</p>\n    <p class=\"author\"><a href=\"javascript:pickyClient.insert('Blake Watters')\">Blake Watters</a></p>\n  </div>\n  <div class=\"actions\">\n    <a href=\"http://cocoadocs.org/docsets/RKKiwiMatchers/0.20.0\">Docs</a>\n    <a href=\"https://github.com/RestKit/RKKiwiMatchers\">Repo</a>\n  </div>\n</li>\n"] }
  
  # Qualifiers.
  #
  it { pods.search('name:kiwi').ids.should == ["Kiwi", "RKKiwiMatchers"] }
  it { pods.search('pod:kiwi').ids.should == ["Kiwi", "RKKiwiMatchers"] }
  
  it { pods.search('author:allen').ids.should == ['Kiwi'] }
  it { pods.search('authors:allen').ids.should == ['Kiwi'] }
  it { pods.search('written:allen').ids.should == ['Kiwi'] }
  it { pods.search('writer:allen').ids.should == ['Kiwi'] }
  it { pods.search('by:allen').ids.should == ['Kiwi'] }
  
  it { pods.search('version:1.0.0').ids.should == ["ABCalendarPicker", "ABGetMe", "ABMultiton", "ACEAutocompleteBar", "ACEDrawingView", "ADBBackgroundCells", "ADBIndexedTableView", "ADiOSUtilities", "ADNLogin", "AeroGear", "AeroGear-OTP", "AFCSVRequestOperation", "AFImageDownloader", "AFJSONPRequestOperation", "AFURLConnectionByteSpeedMeasure", "AGImageChecker", "AKSegmentedControl", "ALAssetsLibrary-CustomPhotoAlbum", "AmazonSDB", "Amplitude-iOS"] }
  
  it { pods.search('dependency:JSONKit').ids.should == ["adlibr", "AWVersionAgent", "BeeFramework", "CocoaSoundCloudUI", "CouchCocoa", "Foursquare-iOS-API", "iOS-Hierarchy-Viewer", "KeenClient", "ObjectiveTumblr", "Quantcast-Measure-iOS4", "SinaWeibo", "TGJSBridge", "Tin", "TouchDB", "WebViewJavascriptBridge"] }
  it { pods.search('dependencies:JSONKit').ids.should == ["adlibr", "AWVersionAgent", "BeeFramework", "CocoaSoundCloudUI", "CouchCocoa", "Foursquare-iOS-API", "iOS-Hierarchy-Viewer", "KeenClient", "ObjectiveTumblr", "Quantcast-Measure-iOS4", "SinaWeibo", "TGJSBridge", "Tin", "TouchDB", "WebViewJavascriptBridge"] }
  it { pods.search('depends:JSONKit').ids.should == ["adlibr", "AWVersionAgent", "BeeFramework", "CocoaSoundCloudUI", "CouchCocoa", "Foursquare-iOS-API", "iOS-Hierarchy-Viewer", "KeenClient", "ObjectiveTumblr", "Quantcast-Measure-iOS4", "SinaWeibo", "TGJSBridge", "Tin", "TouchDB", "WebViewJavascriptBridge"] }
  it { pods.search('using:JSONKit').ids.should == ["adlibr", "AWVersionAgent", "BeeFramework", "CocoaSoundCloudUI", "CouchCocoa", "Foursquare-iOS-API", "iOS-Hierarchy-Viewer", "KeenClient", "ObjectiveTumblr", "Quantcast-Measure-iOS4", "SinaWeibo", "TGJSBridge", "Tin", "TouchDB", "WebViewJavascriptBridge"] }
  it { pods.search('uses:JSONKit').ids.should == ["adlibr", "AWVersionAgent", "BeeFramework", "CocoaSoundCloudUI", "CouchCocoa", "Foursquare-iOS-API", "iOS-Hierarchy-Viewer", "KeenClient", "ObjectiveTumblr", "Quantcast-Measure-iOS4", "SinaWeibo", "TGJSBridge", "Tin", "TouchDB", "WebViewJavascriptBridge"] }
  it { pods.search('use:JSONKit').ids.should == ["adlibr", "AWVersionAgent", "BeeFramework", "CocoaSoundCloudUI", "CouchCocoa", "Foursquare-iOS-API", "iOS-Hierarchy-Viewer", "KeenClient", "ObjectiveTumblr", "Quantcast-Measure-iOS4", "SinaWeibo", "TGJSBridge", "Tin", "TouchDB", "WebViewJavascriptBridge"] }
  it { pods.search('needs:JSONKit').ids.should == ["adlibr", "AWVersionAgent", "BeeFramework", "CocoaSoundCloudUI", "CouchCocoa", "Foursquare-iOS-API", "iOS-Hierarchy-Viewer", "KeenClient", "ObjectiveTumblr", "Quantcast-Measure-iOS4", "SinaWeibo", "TGJSBridge", "Tin", "TouchDB", "WebViewJavascriptBridge"] }
  
  it { pods.search('platform:osx').total.should == 511 }
  it { pods.search('on:osx').total.should == 511 }
  
  it { pods.search('summary:google').ids.should == ["AdMob", "AlgoliaSearchOffline-iOS-SDK", "AlgoliaSearchOffline-OSX-SDK", "ARChromeActivity", "DDGoogleAnalytics-OSX", "GData", "GDataXML-HTML", "Google-API-Client", "Google-Maps-iOS-SDK", "google-plus-ios-sdk", "GoogleAnalytics-iOS-SDK", "GoogleConversionTracking", "GoogleMapsDirection", "GoogleMapsKit", "gtm-oauth", "gtm-oauth2", "HMSegmentedControl", "iOS-GTLYouTube", "LARSAdController", "MTLocation"] }
  
  # No single characters indexed.
  #
  it { pods.search('on:ios "a"').ids.should == [] }
  
  #
  # TODO We need specs. Lots of specs.
  #

end
