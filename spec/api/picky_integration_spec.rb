# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the Picky style API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do

  def pod_ids
    @pod_ids ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.picky.ids.json'
  end

  def names_for_search query, options = {}
    pods.search(query, options).entries.map { |entry| entry[:id] }
  end

  # Testing the format.
  #
  ok { pod_ids.search('on:osx abmultito').entries.should == ['ABMultiton'] }

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.picky.hash.json'
  end

  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0').total.should == 31 }

  # Testing the format.
  #
  ok { pods.search('on:osx afnetworking', sort: 'name').entries.should == [{:id=>"AFNetworking", :platforms=>["ios", "osx"], :version=>"2.3.1", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"2.3.1", :submodules=>true}, :tags=>["network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-RACExtensions", :platforms=>["ios", "osx"], :version=>"0.1.4", :summary=>"AFNetworking-RACExtensions is a delightful extension to the AFNetworking classes for iOS and Mac OS X.", :authors=>{:"Robert Widmann"=>"devteam.codafi@gmail.com"}, :link=>"https://github.com/CodaFi/AFNetworking-RACExtensions", :source=>{:git=>"https://github.com/CodaFi/AFNetworking-RACExtensions.git", :tag=>"0.1.4"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-ReactiveCocoa", :platforms=>["ios", "osx"], :version=>"0.0.2", :summary=>"Make AFNetworking reactive.", :authors=>{:"Tomoki Aonuma"=>"uasi@uasi.jp"}, :link=>"https://github.com/uasi/AFNetworking-ReactiveCocoa", :source=>{:git=>"https://github.com/uasi/AFNetworking-ReactiveCocoa.git", :tag=>"0.0.2"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-Synchronous", :platforms=>["ios", "osx"], :version=>"0.2.0", :summary=>"Synchronous requests for AFNetworking", :authors=>{:"Paul Melnikow"=>"github@paulmelnikow.com"}, :link=>"https://github.com/paulmelnikow/AFNetworking-Synchronous", :source=>{:git=>"https://github.com/paulmelnikow/AFNetworking-Synchronous.git", :tag=>"v0.2.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking2-RACExtensions", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"AFNetworking-RACExtensions is a delightful extension to the AFNetworking classes for iOS and Mac OS X.", :authors=>{:"Robert Widmann"=>"devteam.codafi@gmail.com"}, :link=>"https://github.com/knshiro/AFNetworking-RACExtensions", :source=>{:git=>"https://github.com/knshiro/AFNetworking-RACExtensions.git", :commit=>"d4c6097d3f22be212c66339f850b1be180162747"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFCSVRequestOperation", :platforms=>["ios", "osx"], :version=>"1.0.0", :summary=>"An extension for AFNetworking that provides an interface to parse CSV using CHCSVParser.", :authors=>{:"Stefano Acerbetti"=>"acerbetti@gmail.com"}, :link=>"https://github.com/AFNetworking/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/acerbetti/AFCSVRequestOperation.git", :tag=>"v1.0.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFCoreImageResponseSerializer", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An image response serializer for AFNetworking 2.0 that applies Core Image filters.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer", :source=>{:git=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer.git", :tag=>"0.0.1"}, :tags=>["image"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFDownloadRequestOperation", :platforms=>["ios", "osx"], :version=>"2.0.1", :summary=>"A progressive download operation for AFNetworking.", :authors=>{:"Peter Steinberger"=>"steipete@gmail.com"}, :link=>"https://github.com/steipete/AFDownloadRequestOperation", :source=>{:git=>"https://github.com/steipete/AFDownloadRequestOperation.git", :tag=>"2.0.1"}, :tags=>["progress"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFHARchiver", :platforms=>["ios", "osx"], :version=>"0.2.2", :summary=>"An AFNetworking extension to automatically generate a HTTP Archive file of all of your network requests.", :authors=>{:"Kevin Harwood"=>"kevin.harwood@mutualmobile.com"}, :link=>"https://github.com/mutualmobile/AFHARchiver", :source=>{:git=>"https://github.com/mutualmobile/AFHARchiver.git", :tag=>"0.2.2"}, :tags=>["http", "network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFHTTPClientLogger", :platforms=>["ios", "osx"], :version=>"0.5.0", :summary=>"A configurable HTTP request logger for AFNetworking.", :authors=>{:"Jon Parise"=>"jon@indelible.org"}, :link=>"https://github.com/jparise/AFHTTPClientLogger", :source=>{:git=>"https://github.com/jparise/AFHTTPClientLogger.git", :tag=>"0.5.0"}, :tags=>["http"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFJSONPRequestOperation", :platforms=>["ios", "osx"], :version=>"1.0.0", :summary=>"AFNetworking Extension for the JSONP format.", :authors=>{:"Stefano Acerbetti"=>"acerbetti@gmail.com"}, :link=>"https://github.com/acerbetti/AFJSONPRequestOperation", :source=>{:git=>"https://github.com/acerbetti/AFJSONPRequestOperation.git", :tag=>"v1.0.0"}, :tags=>["json"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFJSONRPCClient", :platforms=>["ios", "osx"], :version=>"2.0.0", :summary=>"A JSON-RPC client build on AFNetworking.", :authors=>{:wiistriker=>"wiistriker@gmail.com", :"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFJSONRPCClient", :source=>{:git=>"https://github.com/AFNetworking/AFJSONRPCClient.git", :tag=>"2.0.0"}, :tags=>["json", "client"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An extension for AFNetworking that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/AFNetworking/AFKissXMLRequestOperation.git", :tag=>"0.0.1"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation@aceontech", :platforms=>["ios", "osx"], :version=>"0.0.4", :summary=>"An extension for AFNetworking 2.x that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/aceontech/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/aceontech/AFKissXMLRequestOperation.git", :tag=>"0.0.4"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation@tonyzonghui", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An extension for AFNetworking that provides an interface to parse XML using KissXML. Specified AFNetworking version.", :authors=>{:"Zhang Zonghui"=>"zhangzonghui01@gmail.com"}, :link=>"https://github.com/tonyzonghui/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/tonyzonghui/AFKissXMLRequestOperation.git", :tag=>"0.0.1"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFMsgPackSerialization", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"A MsgPack request and response serializer for AFNetworking 2.0.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFMsgPackSerialization", :source=>{:git=>"https://github.com/AFNetworking/AFMsgPackSerialization.git", :tag=>"0.0.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-RACExtensions", :platforms=>["ios", "osx"], :version=>"0.1.4", :summary=>"AFNetworking-RACExtensions is a delightful extension to the AFNetworking classes for iOS and Mac OS X.", :authors=>{:"Robert Widmann"=>"devteam.codafi@gmail.com"}, :link=>"https://github.com/CodaFi/AFNetworking-RACExtensions", :source=>{:git=>"https://github.com/CodaFi/AFNetworking-RACExtensions.git", :tag=>"0.1.4"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-ReactiveCocoa", :platforms=>["ios", "osx"], :version=>"0.0.2", :summary=>"Make AFNetworking reactive.", :authors=>{:"Tomoki Aonuma"=>"uasi@uasi.jp"}, :link=>"https://github.com/uasi/AFNetworking-ReactiveCocoa", :source=>{:git=>"https://github.com/uasi/AFNetworking-ReactiveCocoa.git", :tag=>"0.0.2"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-Synchronous", :platforms=>["ios", "osx"], :version=>"0.2.0", :summary=>"Synchronous requests for AFNetworking", :authors=>{:"Paul Melnikow"=>"github@paulmelnikow.com"}, :link=>"https://github.com/paulmelnikow/AFNetworking-Synchronous", :source=>{:git=>"https://github.com/paulmelnikow/AFNetworking-Synchronous.git", :tag=>"v0.2.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}] }

  # Testing a specific order of result ids.
  #
  ok do
    names_for_search('on:osx ki', sort: 'name').should == ["ADNKit", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFKissXMLRequestOperation@tonyzonghui"]
  end

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx a* a', sort: 'name') }.should < 0.01 # seconds
  end

  # Similarity on author.
  #
  ok do
    names_for_search('on:ios mettt~', sort: 'name').should == ["AFCoreImageResponseSerializer", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"]
  end

  # Partial version search.
  #
  ok { names_for_search('on:osx abmultiton 2').should == ['ABMultiton'] }
  ok { names_for_search('on:osx abmultiton 2.').should == ['ABMultiton'] }
  ok { names_for_search('on:osx abmultiton 2.0').should == ['ABMultiton'] }
  ok { names_for_search('on:osx abmultiton 2.0.').should == ['ABMultiton'] }
  ok { names_for_search('on:osx abmultiton 2.0.5').should == ['ABMultiton'] }

  # Platform constrained search (platforms are AND-ed).
  #
  ok { names_for_search('on:osx abmultiton', sort: 'name').should == ["ABMultiton", "ABRequestManager"] }
  ok { names_for_search('on:ios abmultiton', sort: 'name').should == ["ABMultiton", "ABRequestManager"] }
  ok { names_for_search('on:osx on:ios abmultiton', sort: 'name').should == ["ABMultiton", "ABRequestManager"] }

  # Category boosting.
  #
  ok { categories_of(pods.search('on:osx k* a')).should == [%w(platform name), %w(platform author)] }
  ok { categories_of(pods.search('on:osx abmultiton')).should == [%w(platform name), %w(platform dependencies)] }

  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx').total.should == 23 }
  ok { pods.search('platform:os').total.should == 0 }
  ok { pods.search('platform:o').total.should == 0 }

  # Rendering.
  #
  ok { pods.search('afnetworking mattt thompson').entries.should == [{:id=>"AFNetworking", :platforms=>["ios", "osx"], :version=>"2.3.1", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"2.3.1", :submodules=>true}, :tags=>["network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFCoreImageResponseSerializer", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An image response serializer for AFNetworking 2.0 that applies Core Image filters.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer", :source=>{:git=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer.git", :tag=>"0.0.1"}, :tags=>["image"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFHTTPRequestOperationLogger", :platforms=>[], :version=>"1.0.0", :summary=>"AFNetworking Extension for HTTP Request Logging.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFHTTPRequestOperationLogger", :source=>{:git=>"https://github.com/AFNetworking/AFHTTPRequestOperationLogger.git", :tag=>"1.0.0"}, :tags=>["http", "logging"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFJSONRPCClient", :platforms=>["ios", "osx"], :version=>"2.0.0", :summary=>"A JSON-RPC client build on AFNetworking.", :authors=>{:wiistriker=>"wiistriker@gmail.com", :"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFJSONRPCClient", :source=>{:git=>"https://github.com/AFNetworking/AFJSONRPCClient.git", :tag=>"2.0.0"}, :tags=>["json", "client"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An extension for AFNetworking that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/AFNetworking/AFKissXMLRequestOperation.git", :tag=>"0.0.1"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation@aceontech", :platforms=>["ios", "osx"], :version=>"0.0.4", :summary=>"An extension for AFNetworking 2.x that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/aceontech/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/aceontech/AFKissXMLRequestOperation.git", :tag=>"0.0.4"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFMsgPackSerialization", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"A MsgPack request and response serializer for AFNetworking 2.0.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFMsgPackSerialization", :source=>{:git=>"https://github.com/AFNetworking/AFMsgPackSerialization.git", :tag=>"0.0.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworkActivityLogger", :platforms=>["ios"], :version=>"2.0.2", :summary=>"AFNetworking 2.0 Extension for Network Request Logging", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworkActivityLogger", :source=>{:git=>"https://github.com/AFNetworking/AFNetworkActivityLogger.git", :tag=>"2.0.2"}, :tags=>["network", "logging"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFCoreImageResponseSerializer", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An image response serializer for AFNetworking 2.0 that applies Core Image filters.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer", :source=>{:git=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer.git", :tag=>"0.0.1"}, :tags=>["image"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFHTTPRequestOperationLogger", :platforms=>[], :version=>"1.0.0", :summary=>"AFNetworking Extension for HTTP Request Logging.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFHTTPRequestOperationLogger", :source=>{:git=>"https://github.com/AFNetworking/AFHTTPRequestOperationLogger.git", :tag=>"1.0.0"}, :tags=>["http", "logging"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFJSONRPCClient", :platforms=>["ios", "osx"], :version=>"2.0.0", :summary=>"A JSON-RPC client build on AFNetworking.", :authors=>{:wiistriker=>"wiistriker@gmail.com", :"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFJSONRPCClient", :source=>{:git=>"https://github.com/AFNetworking/AFJSONRPCClient.git", :tag=>"2.0.0"}, :tags=>["json", "client"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An extension for AFNetworking that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/AFNetworking/AFKissXMLRequestOperation.git", :tag=>"0.0.1"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation@aceontech", :platforms=>["ios", "osx"], :version=>"0.0.4", :summary=>"An extension for AFNetworking 2.x that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/aceontech/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/aceontech/AFKissXMLRequestOperation.git", :tag=>"0.0.4"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFMsgPackSerialization", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"A MsgPack request and response serializer for AFNetworking 2.0.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFMsgPackSerialization", :source=>{:git=>"https://github.com/AFNetworking/AFMsgPackSerialization.git", :tag=>"0.0.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworkActivityLogger", :platforms=>["ios"], :version=>"2.0.2", :summary=>"AFNetworking 2.0 Extension for Network Request Logging", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworkActivityLogger", :source=>{:git=>"https://github.com/AFNetworking/AFNetworkActivityLogger.git", :tag=>"2.0.2"}, :tags=>["network", "logging"], :deprecated=>false, :deprecated_in_favor_of=>nil}] }

  # Qualifiers.
  #
  ok { names_for_search('name:abmultiton').should == ["ABMultiton"] }
  ok { names_for_search('pod:abmultiton').should == ["ABMultiton"] }

  ok { names_for_search('author:mattt author:thompson').should == ["AFCoreImageResponseSerializer", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"] }
  ok { names_for_search('authors:mattt authors:thompson').should == ["AFCoreImageResponseSerializer", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"] }
  ok { names_for_search('written:mattt written:thompson').should == ["AFCoreImageResponseSerializer", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"] }
  ok { names_for_search('writer:mattt writer:thompson').should == ["AFCoreImageResponseSerializer", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"] }
  # ok { names_for_search('writer:mattt writer:thompson').should == ["AFCoreImageResponseSerializer", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"] }

  ok { names_for_search('version:1.0.0', sort: 'name').should == ["AAShareBubbles", "ABCalendarPicker", "ABGetMe", "ABMultiton", "ABStaticTableViewController", "ACColorKit", "ACDCryptsyAPI", "ACEAutocompleteBar", "ACEDrawingView", "ACEExpandableTextCell", "ACETelPrompt", "ACPButton", "ACPReminder", "ACPScrollMenu", "ADBActors", "ADBBackgroundCells", "ADBDownloadManager", "ADBIndexedTableView", "ADBReasonableTextView", "ADCExtensions"] }

  expected_dependencies = ["ADNKit", "AFCSVRequestOperation", "AFCoreImageResponseSerializer", "AFDownloadRequestOperation", "AFFCCAPIClient", "AFHARchiver", "AFHTTPClientLogger", "AFHTTPFileUpdateOperation", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONPRequestOperation", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFKissXMLRequestOperation@tonyzonghui", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking+AutoRetry", "AFNetworking+streaming", "AFNetworking-MUJSONResponseSerializer"]

  ok { names_for_search('dependency:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('dependencies:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('depends:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('using:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('uses:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('use:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('needs:AFNetworking', sort: 'name').should == expected_dependencies }

  ok { pods.search('platform:osx').total.should == 23 }
  ok { pods.search('on:osx').total.should == 23 }

  ok { names_for_search('summary:network', sort: 'name').should == ["AFHARchiver", "AFNetworkActivityLogger"] }

  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').ids.should == [] }

end
