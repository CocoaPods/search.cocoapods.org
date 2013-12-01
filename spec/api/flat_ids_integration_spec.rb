# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Search Integration Tests' do
  
  before(:all) do
    Picky::Indexes.index
    Picky::Indexes.load
    CocoapodSearch.prepare # Needed to load the data for the rendered search results.
  end

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/api/v2.0/pods/search/flat.ids.json') }
  
  # This is how results should look - a flat list of ids.
  #
  it { pods.search('on:ios 1.0.0', ids: 200).should == ["JASidePanels", "JCDHTTPConnection", "JCNotificationBannerPresenter", "JDDroppableView", "JDFlipNumberView", "JGAFImageCache", "JJCachedAsyncViewDrawing", "JTTargetActionBlock", "JWT", "JXHTTP", "KGNoise", "KISSmetrics", "KJSimpleBinding", "KTOneFingerRotationGestureRecognizer", "KYArcTab", "KYCircleMenu", "Kiwi", "KoaPullToRefresh", "LARSBar", "LARSTorch", "LAWalkthrough", "LKbadgeView", "LLRoundSwitch", "LUKeychainAccess", "Lambda-Alert", "Lasagna-Cookies", "LastFm", "LibComponentLogging-Crashlytics", "LineKit", "LinqToObjectiveC", "LocationPickerView", "MACachedImageView", "MACalendarUI", "MACircleProgressIndicator", "MBAlertView", "MBMvc", "MCDateExtensions", "MCSwipeTableViewCell", "MCUIColorUtils", "MEActionSheet", "MEAlertView", "MFLicensing", "MFMathLib", "MGBox2", "MGSplitViewController", "MHPrettyDate", "MIHGradientView", "MJGFoundation", "MKMapViewZoom", "MKReachableOperationQueue", "MLScreenshot", "MLUIColorAdditions", "MMRecord", "MNColorKit", "MNStaticTableViewController", "MPNotificationView", "MRCurrencyRound", "MSPullToRefreshController", "MSVCLeakHunter", "MTMultipleViewController", "MTRecursiveKVC", "MapBox", "MessagePack", "MessagesTableViewController", "Mixpanel", "libechonest"] }
  
  # Testing a count of results.
  #
  it { pods.search('on:ios 1.0.0', ids: 70).size.should == 66 }

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.005 # seconds
  end

  # Similarity on author.
  #
  it { pods.search('on:ios allan~').should == ["Kiwi"] }
  
  # Partial version search.
  #
  it { pods.search('on:osx kiwi 1').should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.').should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0').should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0.').should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0.0').should == ['Kiwi'] }
  
  # Platform constrained search (platforms are AND-ed).
  #
  it { pods.search('on:osx allen').should == ["Kiwi"] }
  it { pods.search('on:ios allen').should == ["Kiwi"] }
  it { pods.search('on:osx on:ios allen').should == ["Kiwi"] }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  it { pods.search('platform:osx', ids: 200).size.should == 108 }
  it { pods.search('platform:os').size.should == 0 }
  it { pods.search('platform:o').size.should == 0 }
  
  # Qualifiers.
  #
  it { pods.search('name:kiwi').should == ["Kiwi"] }
  it { pods.search('pod:kiwi').should == ["Kiwi"] }
  
  it { pods.search('author:allen').should == ['Kiwi'] }
  it { pods.search('authors:allen').should == ['Kiwi'] }
  it { pods.search('written:allen').should == ['Kiwi'] }
  it { pods.search('writer:allen').should == ['Kiwi'] }
  it { pods.search('by:allen').should == ['Kiwi'] }
  
  expected_dependencies = ["KeenClient"]
  
  it { pods.search('dependency:JSONKit').should == expected_dependencies }
  it { pods.search('dependencies:JSONKit').should == expected_dependencies }
  it { pods.search('depends:JSONKit').should == expected_dependencies }
  it { pods.search('using:JSONKit').should == expected_dependencies }
  it { pods.search('uses:JSONKit').should == expected_dependencies }
  it { pods.search('use:JSONKit').should == expected_dependencies }
  it { pods.search('needs:JSONKit').should == expected_dependencies }
  
  it { pods.search('platform:osx', ids: 200).size.should == 108 }
  it { pods.search('on:osx', ids: 200).size.should == 108 }
  
  it { pods.search('summary:google').should == ["LARSAdController", "MTLocation", "MTStatusBarOverlay"] }
  
  # No single characters indexed.
  #
  it { pods.search('on:ios "a"').should == [] }

end
