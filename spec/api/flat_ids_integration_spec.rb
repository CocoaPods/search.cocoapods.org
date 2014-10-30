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
  ok { pods.search('on:osx kiwi', sort: 'name').should == ["Kiwi", "MSSpec"] }
  
  # Error cases.
  #
  it "does not raise an error when searching for 'pod'" do
    should.not.raise { pods.search 'pod' }
  end
  
  # This is how results should look - a flat list of ids.
  #
  ok { pods.search('on:ios 1.0.0', ids: 200, sort: 'name').should == ["AAShareBubbles", "ABCalendarPicker", "ABGetMe", "ABMultiton", "ABStaticTableViewController", "ACColorKit", "ACEAutocompleteBar", "ACEDrawingView", "ACEExpandableTextCell", "ACETelPrompt", "ACPButton", "ACPReminder", "ACPScrollMenu", "ADBActors", "ADBBackgroundCells", "ADBDownloadManager", "ADBIndexedTableView", "ADBReasonableTextView", "ADCExtensions", "ADClusterMapView", "ADLivelyCollectionView", "ADNActivityCollection", "ADNLogin", "ADTransitionController", "ADiOSUtilities", "AFCSVRequestOperation", "AFDownloadRequestOperation", "AFImageDownloader", "AFJSONPRequestOperation", "AFJSONRPCClient", "AFNetworking-MUJSONResponseSerializer", "AFOAuthClient", "AFSignedHTTPRequestOperationManager", "AFURLConnectionByteSpeedMeasure", "AGEFlagIcons", "AGImageChecker", "AIVerification", "AKSegmentedControl", "ALAssetsLibrary-CustomPhotoAlbum", "ALDClock", "AMSlideMenu", "AMSlideOutController", "AMYServer", "AOCUDL", "AOTestCase", "APAutocompleteTextField", "APAvatarImageView", "APPaginalTableView", "APUtils", "ARASCIISwizzle", "ARChromeActivity", "ARCollectionViewMasonryLayout", "ARGenericTableViewController", "ARTableViewPager", "ARTiledImageView", "ASCRefreshControl", "ASCScreenBrightnessDetector", "ASDepthModal", "ASOAnimatedButton", "AVOSCloud", "AVOSCloudBeta", "AVOSCloudUI", "AVOSCloudUIBeta", "ActiveRecord", "AeroGear", "AeroGear-OTP", "AmazonSDB", "Amplitude-iOS", "Analytics", "Antenna", "AppPaoPaoSDK", "AppSettings", "Appacitive-iOS-SDK", "Appirater", "AppleGuice", "AshObjectiveC", "Ashton", "Aspects", "Asterism", "AstroCocoaPackage", "AsyncImageDownloader", "AutoDescribe", "AutoLayoutDSL", "AutoProperty", "AwesomeMenu", "BAPersistentOperationQueue", "BBlock", "BCVersionCheck", "BDBAttributedButton", "BDBOAuth1Manager", "BDBSpinKitRefreshControl", "BDBSplitViewController", "BDDROneFingerZoomGestureRecognizer", "BDDRScrollViewAdditions", "BDKGeometry", "BDKNotifyHUD", "BDToastAlert", "BEACONinsideSDK", "BFCropInterface", "BFNavigationBarDrawer", "BHTabBar", "BJRangeSliderWithProgress", "BMCredentials", "BMInitialsPlaceholderView", "BOZPongRefreshControl", "BPContextualHelp", "BPForms", "BPPhotoLibrarian", "BREnvironment", "BRFlabbyTable", "BRFullTextSearch", "BRYDescriptionBuilder", "BRYEmailAddressDetective", "BRYEqualsBuilder", "BRYHashCodeBuilder", "BRYMailToURIParser", "BRYSerialAnimationQueue", "BRYSoundEffectPlayer", "BScrollController", "BTBadgeView", "BTButton", "BTKInjector", "BTProgressView", "BTStoreView", "BVReorderTableView", "BVViewList", "BYLBadgeView", "BZGFormField", "BZGFormViewController", "BZGMailgunEmailValidation", "BZObjectStore", "BZipCompression", "Backbeam", "Bars", "Bestly", "Bitlyzer", "BlockAlertsAnd-ActionSheets", "BlocksKit", "BlurImageProcessor", "BlurryModalSegue", "Bolts", "Brett", "BrightCenterSDK", "BrightSDK", "BugButton", "BugSquasher", "ButtonIndicatorView", "C360PopoverBackgroundView", "C360SegmentedControl", "CBDCoreDataToolKit", "CCHLinkTextView", "CCHexagonFlowLayout", "CDI", "CDSTextFieldPicker", "CFShareCircle", "CINBouncyButton", "CJAAssociatedObject", "CJAMacros", "CJKit", "CKBasicAuthUrlUtilities", "CKCalendar", "CKRefreshControl", "CKSelectedTableViewCellFactory", "CKStringUtils", "CLLocation-FESCoordinates", "CLLocationManager-blocks", "CMDataStorage", "CMEnvironment", "CMFactory", "CMMapLauncher", "CMNavBarNotificationView", "CMPopTipView", "COSTouchVisualizer", "CPKenburnsSlideshowView", "CPKenburnsView", "CPPickerView", "CPSlider", "CRFAQTableViewController", "CRGradientLabel", "CRPixellatedView", "CSGrowingTextView", "CSHashKit", "CSLazyLoadController", "CSSSelectorConverter", "CUSLayout", "CUShareCenter", "CWLSynthesizeSingleton", "CXAdjustBlockView", "CXAlertView", "CXCardView", "CXPhotoBrowser", "Camouflage", "CaptainPass", "CardFlight", "CargoBay", "CocoaHTTPServer-Routing", "CocoaSPDY", "CocoaSoundCloudAPI", "CocoaSoundCloudUI", "CollectionUtils"] }
  
  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0', ids: 10000).size.should == 1131 }

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.02 # seconds
  end
  
  # Multiple results and uniqueness.
  #
  ok { pods.search('kiwi', sort: 'name').should == ["AZNSDateKiwiMatcher", "Kiwi", "Kiwi-KIF", "RKKiwiMatchers", "MSSpec", "MockInject", "OKSpecHelper", "AFImageDownloader", "ActiveTouch"] }
  ok { pods.search('name:kiwi', sort: 'name').should == ["AZNSDateKiwiMatcher", "Kiwi", "Kiwi-KIF", "RKKiwiMatchers"] }

  # Similarity on author.
  #
  ok { pods.search('on:ios allan~', sort: 'name').should == ["PWAlignView", "AQGridView", "AZColoredNavigationBar", "CCFScrollingTabBar", "CCFURLResponder", "ReactiveViewModel", "AFS3Client", "Kiwi", "NSDictionary+Accessors"] }
  
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
  ok { pods.search('on:ios allen', sort: 'name').should == ["AFS3Client", "Kiwi", "NSDictionary+Accessors"] }
  ok { pods.search('on:osx on:ios allen').should == ["Kiwi"] }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx', ids: 10000).size.should == 834 }
  ok { pods.search('platform:os').size.should == 0 }
  ok { pods.search('platform:o').size.should == 0 }
  
  # Qualifiers.
  #
  ok { pods.search('name:kiwi allen ding').should == ["Kiwi"] }
  ok { pods.search('pod:kiwi allen ding').should == ["Kiwi"] }
  
  ok { pods.search('kiwi author:allen author:ding').should == ['Kiwi'] }
  ok { pods.search('kiwi authors:allen authors:ding').should == ['Kiwi'] }
  ok { pods.search('kiwi written:allen written:ding').should == ['Kiwi'] }
  ok { pods.search('kiwi writer:allen writer:ding').should == ['Kiwi'] }
  # ok { pods.search('kiwi by:allen by:ding').should == ['Kiwi'] } # by is removed by stopwords.
  
  expected_dependencies = ["AFQiniuClient", "AWVersionAgent", "AppCoreKit", "CordovaLib", "FreshdeskSDK", "Geoloqi-iPhone-SDK", "MKStoreKit", "ObjectiveTumblr", "ShakeReport", "SinaWeibo", "TGJSBridge", "Tin", "XBToolkit", "adlibr", "drupal-ios-sdk", "foursquare-ios-api"]
  
  ok { pods.search('dependency:JSONKit', sort: 'name').should == expected_dependencies }
  ok { pods.search('dependencies:JSONKit', sort: 'name').should == expected_dependencies }
  ok { pods.search('depends:JSONKit', sort: 'name').should == expected_dependencies }
  ok { pods.search('using:JSONKit', sort: 'name').should == expected_dependencies }
  ok { pods.search('uses:JSONKit', sort: 'name').should == expected_dependencies }
  ok { pods.search('use:JSONKit', sort: 'name').should == expected_dependencies }
  ok { pods.search('needs:JSONKit', sort: 'name').should == expected_dependencies }
  
  ok { pods.search('platform:osx', ids: 10000).size.should == 834 }
  ok { pods.search('on:osx', ids: 10000).size.should == 834 }
  
  ok { pods.search('summary:google', sort: 'name').should == ["ARChromeActivity", "AdMob", "AlgoliaSearchOffline-OSX-SDK", "AlgoliaSearchOffline-iOS-SDK", "AnalyticsSDK", "DDGoogleAnalytics-OSX", "DZNPhotoPickerController", "ESTimePicker", "FTGooglePlacesAPI", "GAI-AutomaticSessionManagement", "GDFileManagerKit", "GTMHTTPFetcher", "GVGoogleBannerView", "Google-API-Client", "Google-AdMob-Ads-SDK", "Google-Maps-iOS-SDK", "Google-Maps-iOS-SDK-for-Business", "Google-Mobile-Ads-SDK", "GoogleAds-IMA-iOS-SDK", "GoogleAds-IMA-iOS-SDK-For-AdMob"] }
  
  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').should == [] }

end
