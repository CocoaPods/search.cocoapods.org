# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Search Integration Tests' do
  
  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.flat.ids.json'
  end
  
  # Error cases.
  #
  it "does not raise an error when searching for 'pod'" do
    should.not.raise { pods.search 'pod' }
  end
  
  # This is how results should look - a flat list of ids.
  #
  ok { pods.search('on:ios 1.0.0', ids: 200).should == ["JASidePanels", "JCDHTTPConnection", "JCNotificationBannerPresenter", "JDDroppableView", "JDFlipNumberView", "JGAFImageCache", "JJCachedAsyncViewDrawing", "JTTargetActionBlock", "JWT", "JXHTTP", "KGNoise", "KISSmetrics", "KJSimpleBinding", "KTOneFingerRotationGestureRecognizer", "KYArcTab", "KYCircleMenu", "Kiwi", "KoaPullToRefresh", "LARSBar", "LARSTorch", "LAWalkthrough", "LKbadgeView", "LLRoundSwitch", "LUKeychainAccess", "Lambda-Alert", "Lasagna-Cookies", "LastFm", "LibComponentLogging-Crashlytics", "LineKit", "LinqToObjectiveC", "LocationPickerView", "MACachedImageView", "MACalendarUI", "MACircleProgressIndicator", "MBAlertView", "MBMvc", "MCDateExtensions", "MCSwipeTableViewCell", "MCUIColorUtils", "MEActionSheet", "MEAlertView", "MFLicensing", "MFMathLib", "MGBox2", "MGSplitViewController", "MHPrettyDate", "MIHGradientView", "MJGFoundation", "MKMapViewZoom", "MKReachableOperationQueue", "MLScreenshot", "MLUIColorAdditions", "MMRecord", "MNColorKit", "MNStaticTableViewController", "MPNotificationView", "MRCurrencyRound", "MSPullToRefreshController", "MSVCLeakHunter", "MTMultipleViewController", "MTRecursiveKVC", "MapBox", "MessagePack", "MessagesTableViewController", "Mixpanel", "libechonest"] }
  
  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0', ids: 70).size.should == 66 }

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.005 # seconds
  end

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
  ok { pods.search('platform:osx', ids: 200).size.should == 108 }
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
  
  ok { pods.search('platform:osx', ids: 200).size.should == 108 }
  ok { pods.search('on:osx', ids: 200).size.should == 108 }
  
  ok { pods.search('summary:google').should == ["LARSAdController", "MTLocation", "MTStatusBarOverlay"] }
  
  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').should == [] }

end
