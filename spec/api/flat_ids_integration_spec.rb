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
  ok { pods.search('on:osx kiwi').should == ["Kiwi", "MSSpec"] }
  
  # Error cases.
  #
  it "does not raise an error when searching for 'pod'" do
    should.not.raise { pods.search 'pod' }
  end
  
  # This is how results should look - a flat list of ids.
  #
  ok { pods.search('on:ios 1.0.0', ids: 200).should == ["BlocksKit", "Appirater", "BlockAlertsAnd-ActionSheets", "ARTableViewPager", "BDToastAlert", "ABGetMe", "AwesomeMenu", "AeroGear", "BJRangeSliderWithProgress", "AFAmazonS3Client", "AmazonSDB", "BHTabBar", "AGImageChecker", "BDKNotifyHUD", "ADClusterMapView", "AeroGear-OTP", "AFDownloadRequestOperation", "ADBIndexedTableView", "BDKGeometry", "Ashton", "ALAssetsLibrary-CustomPhotoAlbum", "Appacitive-iOS-SDK", "AFJSONRPCClient", "ACEDrawingView", "AFImageDownloader", "AFCSVRequestOperation", "AFJSONPRequestOperation", "AKSegmentedControl", "ADBBackgroundCells", "ABCalendarPicker", "BFCropInterface", "AMSlideOutController", "ABMultiton", "Analytics", "ADiOSUtilities", "Bitlyzer", "ARGenericTableViewController", "AutoDescribe", "BPPhotoLibrarian", "AppPaoPaoSDK", "Amplitude-iOS", "AFURLConnectionByteSpeedMeasure", "ARChromeActivity", "ADNLogin", "BugSquasher", "Antenna", "ACEAutocompleteBar", "ASDepthModal", "ACEExpandableTextCell", "Backbeam", "AVOSCloud", "AVOSCloudUI", "ADTransitionController", "APUtils", "ACPButton", "Asterism", "BVReorderTableView", "AutoLayoutDSL", "AMYServer", "AeroGear-Push", "BDDROneFingerZoomGestureRecognizer", "BDDRScrollViewAdditions", "AVOSCloudBeta", "AVOSCloudUIBeta", "ACPScrollMenu", "BTBadgeView", "BTButton", "BTProgressView", "BTStoreView", "BrightCenterSDK", "ADBDownloadManager", "BCVersionCheck", "BZipCompression", "ASCRefreshControl", "BZGFormField", "BZGMailgunEmailValidation", "BScrollController", "BZGFormViewController", "AsyncImageDownloader", "BloodMagic", "BDBOAuth1Manager", "APAvatarImageView", "Bestly", "BBlock", "BDBSplitViewController", "AppleGuice", "BlurryModalSegue", "ALDClock", "AstroCocoaPackage", "BugButton", "AOCUDL", "AppSettings", "AAShareBubbles", "APAutocompleteTextField", "APPaginalTableView", "BRYSerialAnimationQueue", "BMInitialsPlaceholderView", "BRYSoundEffectPlayer", "BRYMailToURIParser", "ADCExtensions", "AIVerification", "BRYParseKeyboardNotification", "BOZPongRefreshControl", "BYLBadgeView", "AXRatingView", "BDBAttributedButton", "ActiveRecord", "ASCScreenBrightnessDetector", "Bolts", "BPContextualHelp", "AMSlideMenu", "BRYDescriptionBuilder", "BRYEmailAddressDetective", "BRYEqualsBuilder", "BRYHashCodeBuilder", "BPForms", "AFNetworking-MUJSONResponseSerializer", "ADLivelyCollectionView", "BDBSpinKitRefreshControl", "AshObjectiveC", "ARTiledImageView", "AFOnoResponseSerializer", "ARASCIISwizzle", "BRFlabbyTable", "ARCollectionViewMasonryLayout", "ASOAnimatedButton", "BFNavigationBarDrawer", "ABStaticTableViewController", "AZNSDateKiwiMatcher", "BZObjectStore", "BEACONinsideSDK", "BMCredentials", "BitlyForiOS", "BTKInjector", "AFSignedHTTPRequestOperationManager", "ACPReminder", "ACETelPrompt", "Aspects", "BREnvironment", "ButtonIndicatorView", "BlurImageProcessor", "BAPersistentOperationQueue", "ADNActivityCollection", "Brett", "AGEFlagIcons", "Bars", "BVViewList", "AutoProperty", "AOTestCase", "BSHtmlPageViewController", "ADBReasonableTextView", "ADBActors", "BRFullTextSearch", "BrightSDK", "AFOAuthClient", "ACColorKit", "BMYCircularProgressPullToRefresh", "BMFloatingHeaderCollectionViewLayout", "AKUStoryboardEntry", "AWSCognitoSync", "BSNumPad", "ALLabel", "AFNetworking+ImageActivityIndicator", "AutoLayoutTextViews", "ALDColorBlindEffect", "ADALiOS", "AKLookups", "AKTagsInputView", "AKSlidecks", "Archiver", "AYPieChart", "AYVibrantButton", "AGOTrakt", "BLCStarRatingView", "1PasswordExtension", "Aftership-iOS-SDK", "ADBStateMachine", "AFHTTPSig", "AHTabBarController", "BMAGridPageControl", "AKUTestKit", "BRScroller", "ADVUserDefaults", "AZEncodeURIComponent", "BAPrayerTimes", "ARTEmailSwipe", "AMBTableViewController", "BSDatePickerWithPad", "ATTutorialController", "AdaptiveArpImplIos", "AMPullToRefresh", "Auth0.iOS", "BMYScrollableNavigationBar", "BMPageViewController", "ASYPresenterSupport", "BMYCircleStepView", "ABLightSDK", "AMapNavi", "AKInteractiveBarProxy", "APPagerController"] }
  
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
