# coding: utf-8
#
require File.expand_path '../spec_helper', __FILE__
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Special Cases' do

  def special_cases
    Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.ids.json'
  end

  it 'will survive searching ORed' do
    special_cases.search('ios|osx', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "AQGridView", "AWSiOSSDK", "ActionSheetPicker", "Appirater", "AwesomeMenu", "BlockAlertsAnd-ActionSheets", "BlocksKit", "CHTCollectionViewWaterfallLayout", "CMPopTipView", "CRToast", "Canvas", "CargoBay", "Cedar", "CocoaAsyncSocket", "CocoaHTTPServer", "CocoaLibSpotify", "CocoaLumberjack", "CocoaSPDY"]
  end
  
  it 'will default to popularity with unrecognized sort orders' do
    special_cases.search('a', sort: 'quack').should == ["AFNetworking", "TYPFontAwesome", "ASIHTTPRequest", "CocoaAsyncSocket", "Appirater", "AwesomeMenu", "TTTAttributedLabel", "AQGridView", "InAppSettingKit", "InAppSettingsKit", "AFIncrementalStore", "OHAttributedLabel", "pubnub-api", "TheAmazingAudioEngine", "TPKeyboardAvoiding", "SIAlertView", "BlockAlertsAnd-ActionSheets", "EKAlgorithms", "INAppStoreWindow", "NSDate+TimeAgo"]
  end

  # it 'will correctly find _.m' do
  #   special_cases.search('_.m').should == ['_.m']
  # end

  # it 'will correctly find something split on @' do
  #   special_cases.search('name:AFKissXMLRequestOperation', sort: 'name').should == ["AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFKissXMLRequestOperation@tonyzonghui"]
  #   special_cases.search('name:AFKissXMLRequestOperation@aceontech').should == ['AFKissXMLRequestOperation@aceontech']
  # end

  # it 'will correctly find something split on -' do
  #   expected = ["AFNetworking-MUJSONResponseSerializer"]
  #   special_cases.search('name:AFNetworking', sort: 'name').should == ["AFNetworking", "AFNetworking+AutoRetry", "AFNetworking+streaming", "AFNetworking-MUJSONResponseSerializer", "AFNetworking-MUResponseSerializer", "AFNetworking-RACExtensions", "AFNetworking-ReactiveCocoa", "AFNetworking-Synchronous", "AFNetworking2-RACExtensions"]
  #   special_cases.search('name:MUJSONResponseSerializer').should == expected
  #   special_cases.search('name:AFNetworking-MUJSONResponseSerializer').should == expected
  #   special_cases.search('name:AFNetworking name:MUJSONResponseSerializer').should == expected
  # end
  
  it 'will not crash the search engine' do
    special_cases.search('During%20this%20process%20RubyGems%20might%20ask%20you%20if%20you%20want%20to%20overwrite%20the%20rake%20executable.%20This%20warning%20is%20raised%20because%20the%20rake%20gem%20will%20be%20updated%20as%20part%20of%20this%20process.%20Simply%20confirm%20by%20typing%20y.%20%20If%20you%20do%20not%20want%20to%20grant%20RubyGems%20admin%20privileges%20for%20this%20process,%20you%20can%20tell%20RubyGems%20to%20install%20into%20your%20user%20directory%20by%20passing%20either%20the%20--user-install%20flag%20to%20gem%20install%20or%20by%20configuring%20the%20RubyGems%20environment.%20The%20latter%20is%20in%20our%20opinion%20the%20best%20solution.%20To%20do%20this,%20create%20or%20edit%20the%20.profile%20file%20in%20your%20home%20directory%20and%20add%20or%20amend%20it%20to%20include%20these%20lines:').should == []
  end
  
  it 'will not crash the search engine' do
    special_cases.search('ääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääää').should == []
  end

end
