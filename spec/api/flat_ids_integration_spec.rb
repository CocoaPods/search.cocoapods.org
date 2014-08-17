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
    @pod_hash ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.flat.hash.json'
  end
  
  # Testing the format.
  #
  ok { pod_hash.search('on:osx kiwi').should == [{:id=>"Kiwi", :platforms=>["osx", "ios"], :version=>"2.1", :summary=>"A Behavior Driven Development library for iOS and OS X.", :authors=>{:"Allen Ding"=>"alding@gmail.com", :"Luke Redpath"=>"luke@lukeredpath.co.uk"}, :link=>"https://github.com/allending/Kiwi", :source=>{:git=>"https://github.com/allending/Kiwi.git", :tag=>"2.1"}, :subspecs=>[], :tags=>[], :deprecated => false, :deprecated_in_favor_of => nil}] }
  ok { pod_hash.search('on:ios adjust').should == [{:id=>"AdjustIO", :platforms=>["ios"], :version=>"2.2.0", :summary=>"This is the iOS SDK of AdjustIo. You can read more about it at http://adjust.io.", :authors=>{:"Christian Wellenbrock"=>"welle@adeven.com"}, :link=>"http://adjust.io", :source=>{:git=>"https://github.com/adeven/adjust_ios_sdk.git", :tag=>"v2.2.0"}, :subspecs=>[], :tags=>["http"], :deprecated=>true, :deprecated_in_favor_of=>"Adjust"}] }
  ok { pod_hash.search('on:ios RMStepsController').should == [{:id=>"RMStepsController", :platforms=>["ios"], :version=>"1.0.1", :summary=>"This is an iOS control for guiding users through a process step-by-step", :authors=>{:"Roland Moers"=>"snippets@cooperrs.de"}, :link=>"https://github.com/CooperRS/RMStepsController", :source=>{:git=>"https://github.com/CooperRS/RMStepsController.git", :tag=>"1.0.1"}, :subspecs=>[], :tags=>[], :deprecated=>true, :deprecated_in_favor_of=>nil}]}

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.flat.ids.json'
  end
  
  # Testing the format.
  #
  ok { pods.search('on:osx kiwi').should == ['Kiwi'] }
  
  # Error cases.
  #
  it "does not raise an error when searching for 'pod'" do
    should.not.raise { pods.search 'pod' }
  end
  
  # This is how results should look - a flat list of ids.
  #
  ok { pods.search('on:ios 1.0.0', ids: 200).should == ["JASidePanels", "JCDHTTPConnection", "JCNotificationBannerPresenter", "JDDroppableView", "JDFlipNumberView", "JGAFImageCache", "JJCachedAsyncViewDrawing", "JTTargetActionBlock", "JWT", "JXHTTP", "KGNoise", "KISSmetrics", "KJSimpleBinding", "KTOneFingerRotationGestureRecognizer", "KYArcTab", "KYCircleMenu", "Kiwi", "KoaPullToRefresh", "LARSBar", "LARSTorch", "LAWalkthrough", "LKbadgeView", "LLRoundSwitch", "LUKeychainAccess", "Lambda-Alert", "Lasagna-Cookies", "LastFm", "LibComponentLogging-Crashlytics", "LineKit", "LinqToObjectiveC", "LocationPickerView", "MACachedImageView", "MACalendarUI", "MACircleProgressIndicator", "MBAlertView", "MBMvc", "MCDateExtensions", "MCSwipeTableViewCell", "MCUIColorUtils", "MEActionSheet", "MEAlertView", "MFLicensing", "MFMathLib", "MGBox2", "MGSplitViewController", "MHPrettyDate", "MIHGradientView", "MJGFoundation", "MKMapViewZoom", "MKReachableOperationQueue", "MLScreenshot", "MLUIColorAdditions", "MMRecord", "MNColorKit", "MNStaticTableViewController", "MPNotificationView", "MRCurrencyRound", "MSPullToRefreshController", "MSVCLeakHunter", "MTMultipleViewController", "MTRecursiveKVC", "MessagePack", "MessagesTableViewController", "Mixpanel", "RMStepsController", "libechonest"] }
  
  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0', ids: 70).size.should == 66 }

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.005 # seconds
  end
  
  # Multiple results and uniqueness.
  #
  ok { pods.search('kiwi').should == ["Kiwi", "MockInject"] }
  ok { pods.search('name:kiwi').should == ["Kiwi"] }

  # Similarity on author.
  #
  ok { pods.search('on:ios allan~').should == ["Kiwi"] }
  
  # Partial version search.
  #
  ok { pods.search('on:osx kiwi 1').should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.').should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.0').should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.0.').should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.0.0').should == ['Kiwi'] }
  
  # Platform constrained search (platforms are AND-ed).
  #
  ok { pods.search('on:osx allen').should == ["Kiwi"] }
  ok { pods.search('on:ios allen').should == ["Kiwi"] }
  ok { pods.search('on:osx on:ios allen').should == ["Kiwi"] }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx', ids: 200).size.should == 109 }
  ok { pods.search('platform:os').size.should == 0 }
  ok { pods.search('platform:o').size.should == 0 }
  
  # Qualifiers.
  #
  ok { pods.search('name:kiwi').should == ["Kiwi"] }
  ok { pods.search('pod:kiwi').should == ["Kiwi"] }
  
  ok { pods.search('author:allen').should == ['Kiwi'] }
  ok { pods.search('authors:allen').should == ['Kiwi'] }
  ok { pods.search('written:allen').should == ['Kiwi'] }
  ok { pods.search('writer:allen').should == ['Kiwi'] }
  ok { pods.search('by:allen').should == ['Kiwi'] }
  
  expected_dependencies = ["KeenClient"]
  
  ok { pods.search('dependency:JSONKit').should == expected_dependencies }
  ok { pods.search('dependencies:JSONKit').should == expected_dependencies }
  ok { pods.search('depends:JSONKit').should == expected_dependencies }
  ok { pods.search('using:JSONKit').should == expected_dependencies }
  ok { pods.search('uses:JSONKit').should == expected_dependencies }
  ok { pods.search('use:JSONKit').should == expected_dependencies }
  ok { pods.search('needs:JSONKit').should == expected_dependencies }
  
  ok { pods.search('platform:osx', ids: 200).size.should == 109 }
  ok { pods.search('on:osx', ids: 200).size.should == 109 }
  
  ok { pods.search('summary:google').should == ["LARSAdController", "MTLocation", "MTStatusBarOverlay"] }
  
  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').should == [] }

end
