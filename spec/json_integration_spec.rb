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

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/search.json') }

  # # Bugs.
  # #
  # it { pods.search('pod').entries.should == [] }
  
  # Name without initials.
  #
  it { pods.search('name:sidepanels').ids.should == ["JASidePanels"] }
  
  # Rendering.
  #
  it { pods.search('kiwi 1.0.0').entries.should == [{:id=>"Kiwi",
       :platforms=>["osx", "ios"],
       :version=>"2.1",
       :summary=>"A Behavior Driven Development library for iOS and OS X.",
       :authors=>
        {:"Allen Ding"=>"alding@gmail.com",
         :"Luke Redpath"=>"luke@lukeredpath.co.uk"},
       :link=>"https://github.com/allending/Kiwi",
       :source=>{:git=>"https://github.com/allending/Kiwi.git", :tag=>"2.1"},
       :subspecs=>[],
       :tags=>[]}] }
  
  # Offset.
  #
  it { pods.search('name:s*', :offset => 0).ids.should == ["JASidePanels", "JCAutocompletingSearch", "JCSegueUserInfo", "JKSegueActionViewController", "JMStatefulTableViewController", "JMStaticContentTableViewController", "JNWSpringAnimation", "JRSwizzle", "JTRevealSidebarDemo", "JWSplitView", "KFAppleScriptHandlerAdditions", "KGStatusBar", "KISSmetrics", "KJSimpleBinding", "KLExpandingSelect", "KLHorizontalSelect", "KNMultiItemSelector", "KNSemiModalViewController", "KSGithubStatusAPI", "LLRoundSwitch"] }
  it { pods.search('name:s*', :offset => 19).ids.should == ["LLRoundSwitch", "LayerSprites", "LibComponentLogging-SystemLog", "MASShortcut", "MCSimpleTables", "MCSwipeTableViewCell", "MDCScrollBarLabel", "MDCShineEffect", "MEActionSheet", "MFSideMenu", "MGSplitViewController", "MHKitchenSink", "MIHSliderView", "MKStoreKit", "MKiCloudSync", "MLPSpotlight", "MLScreenshot", "MNStaticTableViewController", "MRSubtleButton", "MSNavigationSwipeController"] }
  it { pods.search('name:s*', :offset => 38).ids.should == ["MSNavigationSwipeController", "MTFittedScrollView", "MTStackViewController", "MTStackableNavigationController", "MTStatusBarOverlay", "MTStringAttributes", "MTZTiltReflectionSlider", "MWFSlideNavigationViewController", "MasterShareSDK", "MendeleySDK", "MixiSDK", "MoPubSDK", "Moodstocks-iOS-SDK", "konashi-ios-sdk"] }
  it { pods.search('name:s*', :offset => 57).ids.should == [] }
  
  it { pods.search('s*', :offset => 0).ids.should == ["JASidePanels", "JCAutocompletingSearch", "JCSegueUserInfo", "JKSegueActionViewController", "JMStatefulTableViewController", "JMStaticContentTableViewController", "JNWSpringAnimation", "JRSwizzle", "JTRevealSidebarDemo", "JWSplitView", "KFAppleScriptHandlerAdditions", "KGStatusBar", "KISSmetrics", "KJSimpleBinding", "KLExpandingSelect", "KLHorizontalSelect", "KNMultiItemSelector", "KNSemiModalViewController", "KSGithubStatusAPI", "LLRoundSwitch"] }
  it { pods.search('s*', :offset => 19).ids.should == ["LLRoundSwitch", "LayerSprites", "LibComponentLogging-SystemLog", "MASShortcut", "MCSimpleTables", "MCSwipeTableViewCell", "MDCScrollBarLabel", "MDCShineEffect", "MEActionSheet", "MFSideMenu", "MGSplitViewController", "MHKitchenSink", "MIHSliderView", "MKStoreKit", "MKiCloudSync", "MLPSpotlight", "MLScreenshot", "MNStaticTableViewController", "MRSubtleButton", "MSNavigationSwipeController"] }
  it { pods.search('s*', :offset => 38).ids.should == ["MSNavigationSwipeController", "MTFittedScrollView", "MTStackViewController", "MTStackableNavigationController", "MTStatusBarOverlay", "MTStringAttributes", "MTZTiltReflectionSlider", "MWFSlideNavigationViewController", "MasterShareSDK", "MendeleySDK", "MixiSDK", "MoPubSDK", "Moodstocks-iOS-SDK", "konashi-ios-sdk", "JIRAConnect", "JJCachedAsyncViewDrawing", "JPSThumbnailAnnotation", "JSMessagesViewController", "JSNotifier", "JSProgressHUD"] }
  it { pods.search('s*', :offset => 57).ids.should == ["JSProgressHUD", "KIF", "KKGridView", "KLSDateLabel", "KSADNTwitterFormatter", "KSCustomUIPopover", "KSDeferred", "KSGithubStatusAPI", "KSInstapaperAPI", "KSLabel", "KSReachability", "KVOBlocks", "KoaPullToRefresh", "LEColorPicker", "LXPagingViews", "LXReorderableCollectionViewFlowLayout", "LibComponentLogging-Crashlytics", "LibYAML", "Localytics", "Localytics-iOS-Client"] }

end
