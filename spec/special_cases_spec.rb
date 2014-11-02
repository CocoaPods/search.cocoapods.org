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

  it 'will default to popularity with unrecognized sort orders' do
    special_cases.search('a', sort: 'quack').should == ["AFNetworking", "AFIncrementalStore", "AFDownloadRequestOperation", "ADClusterMapView", "ABCalendarPicker", "ADTransitionController", "ADNKit", "AFAmazonS3Client", "ABPadLockScreen", "AFCache", "ACEDrawingView", "AFHTTPRequestOperationLogger", "ABCustomUINavigationController", "500px-iOS-api", "AFJSONRPCClient", "AFNetworking-RACExtensions", "AAShareBubbles", "ADLivelyCollectionView", "AFNetworkActivityLogger", "ACEView"]
  end

  # it 'will correctly find _.m' do
  #   special_cases.search('_.m').should == ['_.m']
  # end

  it 'will correctly find something split on @' do
    special_cases.search('name:AFKissXMLRequestOperation', sort: 'name').should == ["AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFKissXMLRequestOperation@tonyzonghui"]
    special_cases.search('name:AFKissXMLRequestOperation@aceontech').should == ['AFKissXMLRequestOperation@aceontech']
  end

  it 'will correctly find something split on -' do
    expected = ["AFNetworking-MUJSONResponseSerializer"]
    special_cases.search('name:AFNetworking', sort: 'name').should == ["AFNetworking", "AFNetworking+AutoRetry", "AFNetworking+streaming", "AFNetworking-MUJSONResponseSerializer", "AFNetworking-MUResponseSerializer", "AFNetworking-RACExtensions", "AFNetworking-ReactiveCocoa", "AFNetworking-Synchronous", "AFNetworking2-RACExtensions"]
    special_cases.search('name:MUJSONResponseSerializer').should == expected
    special_cases.search('name:AFNetworking-MUJSONResponseSerializer').should == expected
    special_cases.search('name:AFNetworking name:MUJSONResponseSerializer').should == expected
  end

end
