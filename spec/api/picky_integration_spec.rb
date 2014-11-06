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
  ok { pod_ids.search('on:osx afnetwork').entries.should == ["AFNetworking"] }

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.picky.hash.json'
  end

  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0').total.should == 40 }

  # Testing the format.
  #
  ok { pods.search('on:osx afnetworking', sort: 'name').entries.should == [{:id=>"AFNetworking", :platforms=>["ios", "osx"], :version=>"2.3.1", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"2.3.1", :submodules=>true}, :tags=>["network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"CargoBay", :platforms=>["ios", "osx"], :version=>"2.1.0", :summary=>"The Essential StoreKit Companion.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/mattt/CargoBay", :source=>{:git=>"https://github.com/mattt/CargoBay.git", :tag=>"2.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"GroundControl", :platforms=>["ios", "osx"], :version=>"2.1.0", :summary=>"Remote configuration for iOS.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/mattt/GroundControl", :source=>{:git=>"https://github.com/mattt/GroundControl.git", :tag=>"2.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}] }

  # Testing a specific order of result ids.
  #
  ok do
    names_for_search('on:osx ki', sort: 'name').should == ["BlocksKit", "PromiseKit", "RestKit", "Expecta", "KVOController", "pop"]
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
    names_for_search('on:ios mettt~', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "CargoBay", "GroundControl", "TTTAttributedLabel"]
  end

  # Partial version search.
  #
  expected = ["CargoBay", "GroundControl", "AFNetworking"]
  ok { names_for_search('on:osx afnetworking 2', sort: 'name').should == expected }
  ok { names_for_search('on:osx afnetworking 2.', sort: 'name').should == expected }
  ok { names_for_search('on:osx afnetworking 2.0', sort: 'name').should == expected }
  ok { names_for_search('on:osx afnetworking 2.0.', sort: 'name').should == expected }
  ok { names_for_search('on:osx afnetworking 2.0.0', sort: 'name').should == expected }

  # Platform constrained search (platforms are AND-ed).
  #
  expected = ["AFNetworking", "AFIncrementalStore", "AFIncrementalStore", "CargoBay", "GroundControl"]
  ok { names_for_search('on:osx afnetworking', sort: 'name').should == expected }
  ok { names_for_search('on:ios afnetworking', sort: 'name').should == expected + ["REActivityViewController"] }
  ok { names_for_search('on:osx on:ios afnetworking', sort: 'name').should == expected }

  # Category boosting.
  #
  # ok { categories_of(pods.search('on:ios s* a*')).should == [%w(platform name), %w(platform author)] }
  # ok { categories_of(pods.search('on:ios a*')).should == [%w(platform name), %w(platform dependencies)] }

  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx').total.should == 38 }
  ok { pods.search('platform:os').total.should == 0 }
  ok { pods.search('platform:o').total.should == 0 }

  # Rendering.
  #
  ok { pods.search('afnetworking mattt thompson', sort: 'name').entries.should == [{:id=>"AFNetworking", :platforms=>["ios", "osx"], :version=>"2.3.1", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"2.3.1", :submodules=>true}, :tags=>["network"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFOAuth2Client", :platforms=>[], :version=>"0.1.2", :summary=>"AFNetworking Extension for OAuth 2 Authentication.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFOAuth2Client", :source=>{:git=>"https://github.com/AFNetworking/AFOAuth2Client.git", :tag=>"0.1.2"}, :tags=>["authentication"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"CargoBay", :platforms=>["ios", "osx"], :version=>"2.1.0", :summary=>"The Essential StoreKit Companion.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/mattt/CargoBay", :source=>{:git=>"https://github.com/mattt/CargoBay.git", :tag=>"2.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"GroundControl", :platforms=>["ios", "osx"], :version=>"2.1.0", :summary=>"Remote configuration for iOS.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/mattt/GroundControl", :source=>{:git=>"https://github.com/mattt/GroundControl.git", :tag=>"2.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFIncrementalStore", :platforms=>["ios", "osx"], :version=>"0.5.1", :summary=>"Core Data Persistence with AFNetworking, Done Right.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFIncrementalStore", :source=>{:git=>"https://github.com/AFNetworking/AFIncrementalStore.git", :tag=>"0.5.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AFOAuth2Client", :platforms=>[], :version=>"0.1.2", :summary=>"AFNetworking Extension for OAuth 2 Authentication.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFOAuth2Client", :source=>{:git=>"https://github.com/AFNetworking/AFOAuth2Client.git", :tag=>"0.1.2"}, :tags=>["authentication"], :deprecated=>false, :deprecated_in_favor_of=>nil}] }

  # Qualifiers.
  #
  expected = ["AFNetworking"]
  ok { names_for_search('name:afnetworking').should == expected }
  ok { names_for_search('pod:afnetworking').should == expected }

  expected = ["AFIncrementalStore", "AFNetworking", "AFOAuth2Client", "CargoBay", "FormatterKit", "GroundControl", "TTTAttributedLabel"]
  ok { names_for_search('author:mattt author:thompson', sort: 'name').should == expected }
  ok { names_for_search('authors:mattt authors:thompson', sort: 'name').should == expected }
  ok { names_for_search('written:mattt written:thompson', sort: 'name').should == expected }
  ok { names_for_search('writer:mattt writer:thompson', sort: 'name').should == expected }
  # ok { names_for_search('writer:mattt writer:thompson').should == expected }

  ok { names_for_search('version:1.0.0', sort: 'name').should == ["Appirater", "AwesomeMenu", "BlockAlertsAnd-ActionSheets", "BlocksKit", "Bolts", "CMPopTipView", "CargoBay", "CocoaLumberjack", "CocoaSPDY", "Cordova", "DTCoreText", "EAIntroView", "ECSlidingViewController", "FMDB", "FormatterKit", "GroundControl", "HPGrowingTextView", "JASidePanels", "KIF", "KVOController"] }

  expected_dependencies = ["AFIncrementalStore", "AFOAuth2Client", "CargoBay", "GroundControl", "REActivityViewController"]
  ok { names_for_search('dependency:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('dependencies:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('depends:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('using:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('uses:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('use:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { names_for_search('needs:AFNetworking', sort: 'name').should == expected_dependencies }

  ok { pods.search('platform:osx').total.should == 38 }
  ok { pods.search('on:osx').total.should == 38 }

  ok { names_for_search('summary:data', sort: 'name').should == ["AFIncrementalStore", "FCModel", "FXForms", "JSONModel", "MagicalRecord", "ObjectiveRecord", "PonyDebugger", "RETableViewManager", "TTTAttributedLabel"] }

  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').ids.should == [] }

end
