# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Search Integration Tests' do

  # In these tests we are abusing the Picky client a little.
  #

  def pod_hash
    @pod_hash ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.hash.json'
  end

  # Testing the format.
  #
  ok { pod_hash.search('on:osx afnetworking', sort: 'name').should == [{:id=>"AFNetworking", :platforms=>["ios", "osx"], :version=>"2.3.1", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"2.3.1", :submodules=>true}, :tags=>["network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-RACExtensions", :platforms=>["ios", "osx"], :version=>"0.1.4", :summary=>"AFNetworking-RACExtensions is a delightful extension to the AFNetworking classes for iOS and Mac OS X.", :authors=>{:"Robert Widmann"=>"devteam.codafi@gmail.com"}, :link=>"https://github.com/CodaFi/AFNetworking-RACExtensions", :source=>{:git=>"https://github.com/CodaFi/AFNetworking-RACExtensions.git", :tag=>"0.1.4"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-ReactiveCocoa", :platforms=>["ios", "osx"], :version=>"0.0.2", :summary=>"Make AFNetworking reactive.", :authors=>{:"Tomoki Aonuma"=>"uasi@uasi.jp"}, :link=>"https://github.com/uasi/AFNetworking-ReactiveCocoa", :source=>{:git=>"https://github.com/uasi/AFNetworking-ReactiveCocoa.git", :tag=>"0.0.2"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking-Synchronous", :platforms=>["ios", "osx"], :version=>"0.2.0", :summary=>"Synchronous requests for AFNetworking", :authors=>{:"Paul Melnikow"=>"github@paulmelnikow.com"}, :link=>"https://github.com/paulmelnikow/AFNetworking-Synchronous", :source=>{:git=>"https://github.com/paulmelnikow/AFNetworking-Synchronous.git", :tag=>"v0.2.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFNetworking2-RACExtensions", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"AFNetworking-RACExtensions is a delightful extension to the AFNetworking classes for iOS and Mac OS X.", :authors=>{:"Robert Widmann"=>"devteam.codafi@gmail.com"}, :link=>"https://github.com/knshiro/AFNetworking-RACExtensions", :source=>{:git=>"https://github.com/knshiro/AFNetworking-RACExtensions.git", :commit=>"d4c6097d3f22be212c66339f850b1be180162747"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFCSVRequestOperation", :platforms=>["ios", "osx"], :version=>"1.0.0", :summary=>"An extension for AFNetworking that provides an interface to parse CSV using CHCSVParser.", :authors=>{:"Stefano Acerbetti"=>"acerbetti@gmail.com"}, :link=>"https://github.com/AFNetworking/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/acerbetti/AFCSVRequestOperation.git", :tag=>"v1.0.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFCoreImageResponseSerializer", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An image response serializer for AFNetworking 2.0 that applies Core Image filters.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer", :source=>{:git=>"https://github.com/AFNetworking/AFCoreImageResponseSerializer.git", :tag=>"0.0.1"}, :tags=>["image"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFDownloadRequestOperation", :platforms=>["ios", "osx"], :version=>"2.0.1", :summary=>"A progressive download operation for AFNetworking.", :authors=>{:"Peter Steinberger"=>"steipete@gmail.com"}, :link=>"https://github.com/steipete/AFDownloadRequestOperation", :source=>{:git=>"https://github.com/steipete/AFDownloadRequestOperation.git", :tag=>"2.0.1"}, :tags=>["progress"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFHARchiver", :platforms=>["ios", "osx"], :version=>"0.2.2", :summary=>"An AFNetworking extension to automatically generate a HTTP Archive file of all of your network requests.", :authors=>{:"Kevin Harwood"=>"kevin.harwood@mutualmobile.com"}, :link=>"https://github.com/mutualmobile/AFHARchiver", :source=>{:git=>"https://github.com/mutualmobile/AFHARchiver.git", :tag=>"0.2.2"}, :tags=>["http", "network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFHTTPClientLogger", :platforms=>["ios", "osx"], :version=>"0.5.0", :summary=>"A configurable HTTP request logger for AFNetworking.", :authors=>{:"Jon Parise"=>"jon@indelible.org"}, :link=>"https://github.com/jparise/AFHTTPClientLogger", :source=>{:git=>"https://github.com/jparise/AFHTTPClientLogger.git", :tag=>"0.5.0"}, :tags=>["http"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFJSONPRequestOperation", :platforms=>["ios", "osx"], :version=>"1.0.0", :summary=>"AFNetworking Extension for the JSONP format.", :authors=>{:"Stefano Acerbetti"=>"acerbetti@gmail.com"}, :link=>"https://github.com/acerbetti/AFJSONPRequestOperation", :source=>{:git=>"https://github.com/acerbetti/AFJSONPRequestOperation.git", :tag=>"v1.0.0"}, :tags=>["json"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFJSONRPCClient", :platforms=>["ios", "osx"], :version=>"2.0.0", :summary=>"A JSON-RPC client build on AFNetworking.", :authors=>{:wiistriker=>"wiistriker@gmail.com", :"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFJSONRPCClient", :source=>{:git=>"https://github.com/AFNetworking/AFJSONRPCClient.git", :tag=>"2.0.0"}, :tags=>["json", "client"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An extension for AFNetworking that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/AFNetworking/AFKissXMLRequestOperation.git", :tag=>"0.0.1"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation@aceontech", :platforms=>["ios", "osx"], :version=>"0.0.4", :summary=>"An extension for AFNetworking 2.x that provides an interface to parse XML using KissXML.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/aceontech/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/aceontech/AFKissXMLRequestOperation.git", :tag=>"0.0.4"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFKissXMLRequestOperation@tonyzonghui", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"An extension for AFNetworking that provides an interface to parse XML using KissXML. Specified AFNetworking version.", :authors=>{:"Zhang Zonghui"=>"zhangzonghui01@gmail.com"}, :link=>"https://github.com/tonyzonghui/AFKissXMLRequestOperation", :source=>{:git=>"https://github.com/tonyzonghui/AFKissXMLRequestOperation.git", :tag=>"0.0.1"}, :tags=>["xml"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFMsgPackSerialization", :platforms=>["ios", "osx"], :version=>"0.0.1", :summary=>"A MsgPack request and response serializer for AFNetworking 2.0.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFMsgPackSerialization", :source=>{:git=>"https://github.com/AFNetworking/AFMsgPackSerialization.git", :tag=>"0.0.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"ADNKit", :platforms=>["ios", "osx"], :version=>"1.3.1", :summary=>"Objective-C framework for building App.net applications on iOS and OS X.", :authors=>{:"Joel Levin"=>"joellevin.email@gmail.com"}, :link=>"https://github.com/joeldev/ADNKit", :source=>{:git=>"https://github.com/joeldev/ADNKit.git", :tag=>"1.3.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}]}

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.ids.json'
  end

  # Testing the format.
  #
  ok { pods.search('on:osx afnetworking', sort: 'name').should == ["AFNetworking", "AFNetworking-RACExtensions", "AFNetworking-ReactiveCocoa", "AFNetworking-Synchronous", "AFNetworking2-RACExtensions", "AFCSVRequestOperation", "AFCoreImageResponseSerializer", "AFDownloadRequestOperation", "AFHARchiver", "AFHTTPClientLogger", "AFIncrementalStore", "AFJSONPRequestOperation", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFKissXMLRequestOperation@tonyzonghui", "AFMsgPackSerialization", "ADNKit"] }

  # Error cases.
  #
  it "does not raise an error when searching for 'pod'" do
    should.not.raise { pods.search 'pod' }
  end

  # This is how results should look - a flat list of ids.
  #
  ok { pods.search('on:ios 1.0.0', ids: 200, sort: 'name').should == ["AAShareBubbles", "ABCalendarPicker", "ABGetMe", "ABMultiton", "ABStaticTableViewController", "ACColorKit", "ACEAutocompleteBar", "ACEDrawingView", "ACEExpandableTextCell", "ACETelPrompt", "ACPButton", "ACPReminder", "ACPScrollMenu", "ADBActors", "ADBBackgroundCells", "ADBDownloadManager", "ADBIndexedTableView", "ADBReasonableTextView", "ADCExtensions", "ADClusterMapView", "ADLivelyCollectionView", "ADNActivityCollection", "ADNLogin", "ADTransitionController", "ADiOSUtilities", "AFCSVRequestOperation", "AFDownloadRequestOperation", "AFImageDownloader", "AFJSONPRequestOperation", "AFJSONRPCClient", "AFNetworking-MUJSONResponseSerializer"] }

  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0', ids: 10_000).size.should == 31 }

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.02 # seconds
  end

  # Multiple results and uniqueness.
  #
  ok { pods.search('kiwi', sort: 'name').should == ["AFImageDownloader"] }
  ok { pods.search('name:afnetworking', sort: 'name').should == ["AFNetworking", "AFNetworking+AutoRetry", "AFNetworking+streaming", "AFNetworking-MUJSONResponseSerializer", "AFNetworking-MUResponseSerializer", "AFNetworking-RACExtensions", "AFNetworking-ReactiveCocoa", "AFNetworking-Synchronous", "AFNetworking2-RACExtensions"] }

  # Similarity on author.
  #
  ok { pods.search('on:ios mettt~', sort: 'name').should == ["AFCoreImageResponseSerializer", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"] }

  # Partial version search.
  #
  expected_results_pre_1_0 = ["ADNKit", "AFCSVRequestOperation", "AFDownloadRequestOperation", "AFJSONPRequestOperation", "AFJSONRPCClient", "AFNetworking"]
  ok { pods.search('on:osx afnetworking 1', sort: 'name').should == expected_results_pre_1_0 }
  ok { pods.search('on:osx afnetworking 1.', sort: 'name').should == expected_results_pre_1_0 }
  ok { pods.search('on:osx afnetworking 1.0', sort: 'name').should == expected_results_pre_1_0 }
  ok { pods.search('on:osx afnetworking 1.0.', sort: 'name').should == ["AFCSVRequestOperation", "AFDownloadRequestOperation", "AFJSONPRequestOperation", "AFJSONRPCClient", "AFNetworking"] }
  ok { pods.search('on:osx afnetworking 1.0.0', sort: 'name').should == ["AFCSVRequestOperation", "AFDownloadRequestOperation", "AFJSONPRequestOperation", "AFJSONRPCClient"] }

  # Platform constrained search (platforms are AND-ed).
  #
  ok { pods.search('on:osx mattt').should == ["AFCoreImageResponseSerializer", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworking"] }
  ok { pods.search('on:ios mattt', sort: 'name').should == ["AFCoreImageResponseSerializer", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking"] }
  ok { pods.search('on:osx on:ios mattt').should == ["AFCoreImageResponseSerializer", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworking"] }

  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx', ids: 10_000).size.should == 23 }
  ok { pods.search('platform:os').size.should == 0 }
  ok { pods.search('platform:o').size.should == 0 }

  # Qualifiers.
  #
  ok { pods.search('name:afnetworking mattt thompson').should == ["AFNetworking"] }
  ok { pods.search('pod:afnetworking mattt thompson').should == ["AFNetworking"] }

  expected = ["AFNetworking", "AFCoreImageResponseSerializer", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFMsgPackSerialization", "AFNetworkActivityLogger"]
  ok { pods.search('afnetworking author:mattt author:thompson').should == expected }
  ok { pods.search('afnetworking authors:mattt authors:thompson').should == expected }
  ok { pods.search('afnetworking written:mattt written:thompson').should == expected }
  ok { pods.search('afnetworking writer:mattt writer:thompson').should == expected }
  # ok { pods.search('kiwi by:allen by:ding').should == ['Kiwi'] } # by is removed by stopwords.

  expected_dependencies = ["ADNKit", "AFCSVRequestOperation", "AFCoreImageResponseSerializer", "AFDownloadRequestOperation", "AFFCCAPIClient", "AFHARchiver", "AFHTTPClientLogger", "AFHTTPFileUpdateOperation", "AFHTTPRequestOperationLogger", "AFIncrementalStore", "AFJSONPRequestOperation", "AFJSONRPCClient", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFKissXMLRequestOperation@tonyzonghui", "AFMsgPackSerialization", "AFNetworkActivityLogger", "AFNetworking+AutoRetry", "AFNetworking+streaming", "AFNetworking-MUJSONResponseSerializer"]
  ok { pods.search('dependency:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('dependencies:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('depends:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('using:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('uses:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('use:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('needs:AFNetworking', sort: 'name').should == expected_dependencies }

  ok { pods.search('platform:osx', ids: 10_000).size.should == 23 }
  ok { pods.search('on:osx', ids: 10_000).size.should == 23 }

  ok { pods.search('summary:networking', sort: 'name').should == ["AFNetworking"] }

  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').should == [] }

end
