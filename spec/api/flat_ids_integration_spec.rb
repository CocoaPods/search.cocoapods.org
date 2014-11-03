# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Flat Ids Integration Tests' do

  # In these tests we are abusing the Picky client a little.
  #

  def pod_hash
    @pod_hash ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.hash.json'
  end

  # Testing the format.
  #
  ok { pod_hash.search('on:osx afnetworking', sort: 'name').should == [{:id=>"AFNetworking", :platforms=>["ios", "osx"], :version=>"2.3.1", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"2.3.1", :submodules=>true}, :tags=>["network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"CargoBay", :platforms=>["ios", "osx"], :version=>"2.1.0", :summary=>"The Essential StoreKit Companion.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/mattt/CargoBay", :source=>{:git=>"https://github.com/mattt/CargoBay.git", :tag=>"2.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"GroundControl", :platforms=>["ios", "osx"], :version=>"2.1.0", :summary=>"Remote configuration for iOS.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/mattt/GroundControl", :source=>{:git=>"https://github.com/mattt/GroundControl.git", :tag=>"2.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}] }

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.ids.json'
  end

  # Testing the format.
  #
  ok { pods.search('on:osx afnetworking', sort: 'name').should == ["AFNetworking", "AFIncrementalStore", "CargoBay", "GroundControl"] }

  # Error cases.
  #
  it "does not raise an error when searching for 'pod'" do
    should.not.raise { pods.search 'pod' }
  end

  # This is how results should look - a flat list of ids.
  #
  ok { pods.search('on:ios 1.0.0', ids: 200, sort: 'name').should == ["Appirater", "Aspects", "AwesomeMenu", "BlockAlertsAnd-ActionSheets", "BlocksKit", "Bolts", "CMPopTipView", "CargoBay", "CocoaSPDY", "DTCoreText", "EAIntroView", "ECSlidingViewController", "GroundControl", "HPGrowingTextView", "JASidePanels", "KIF", "KVOController", "M13ProgressSuite", "MCSwipeTableViewCell", "MSDynamicsDrawerViewController", "MZFormSheetController", "MessageBarManager", "Nimbus", "ODRefreshControl", "Ono", "OpenUDID", "PHFComposeBarView", "PSTCollectionView", "ReactiveCocoa", "SMCalloutView", "SSToolkit", "Shimmer", "TMCache", "TimesSquare", "Tweaks", "UISS", "UIView+AutoLayout", "VCTransitionsLibrary", "ViewDeck", "WEPopover", "XLForm", "objc-TimesSquare", "pop", "scifihifi-iphone", "scifihifi-iphone-security"] }

  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0', ids: 10_000).size.should == 45 }

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.02 # seconds
  end

  # Multiple results and uniqueness.
  #
  ok { pods.search('afnetworking', sort: 'name').should == ["AFNetworking", "AFIncrementalStore", "CargoBay", "GroundControl"] }

  # Similarity on author.
  #
  ok { pods.search('on:ios mettt~', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "CargoBay", "GroundControl", "Ono", "TTTAttributedLabel"] }

  # Partial version search.
  #
  expected_results_pre_1_0_0 = ["CargoBay", "GroundControl", "AFNetworking"]
  ok { pods.search('on:osx afnetworking 1', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { pods.search('on:osx afnetworking 1.', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { pods.search('on:osx afnetworking 1.0', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { pods.search('on:osx afnetworking 1.0.', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { pods.search('on:osx afnetworking 1.0.0', sort: 'name').should == ["CargoBay", "GroundControl"] }

  # Platform constrained search (platforms are AND-ed).
  #
  ok { pods.search('on:osx mattt', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "CargoBay", "GroundControl", "Ono"] }
  ok { pods.search('on:ios mattt', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "CargoBay", "GroundControl", "Ono", "TTTAttributedLabel"] }
  ok { pods.search('on:osx on:ios mattt', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "CargoBay", "GroundControl", "Ono"] }

  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx', ids: 10_000).size.should == 42 }
  ok { pods.search('platform:os').size.should == 0 }
  ok { pods.search('platform:o').size.should == 0 }

  # Qualifiers.
  #
  ok { pods.search('name:afnetworking mattt thompson').should == ["AFNetworking"] }
  ok { pods.search('pod:afnetworking mattt thompson').should == ["AFNetworking"] }

  expected = ["AFNetworking", "AFIncrementalStore", "CargoBay", "GroundControl"]
  ok { pods.search('afnetworking author:mattt author:thompson', sort: 'name').should == expected }
  ok { pods.search('afnetworking authors:mattt authors:thompson', sort: 'name').should == expected }
  ok { pods.search('afnetworking written:mattt written:thompson', sort: 'name').should == expected }
  ok { pods.search('afnetworking writer:mattt writer:thompson', sort: 'name').should == expected }
  # ok { pods.search('kiwi by:allen by:ding').should == ['Kiwi'] } # by is removed by stopwords.

  expected_dependencies = ["AFIncrementalStore", "CargoBay", "GroundControl"]
  ok { pods.search('dependency:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('dependencies:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('depends:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('using:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('uses:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('use:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { pods.search('needs:AFNetworking', sort: 'name').should == expected_dependencies }

  ok { pods.search('platform:osx', ids: 10_000).size.should == 42 }
  ok { pods.search('on:osx', ids: 10_000).size.should == 42 }

  ok { pods.search('summary:networking', sort: 'name').should == ["AFNetworking", "CocoaAsyncSocket"] }

  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').should == [] }

end
