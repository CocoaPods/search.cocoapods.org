# coding: utf-8
# frozen_string_literal: true
#
require File.expand_path '../spec_helper', __FILE__
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Special Cases' do

  def special_cases
    Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.ids.json'
  end

  def first_three_names_for_search(query, options = {})
    special_cases.search(query, options).first(3)
  end

  # TODO These tests are useless (and fail) - it should use a pod's name which is found in another pod.
  #
  # it 'will find AFNetworking at the first position if exact - despite negative popularity sorting' do
  #   first_three_names_for_search('name:AFnetworking', sort: '-popularity').should == ["AFNetworking", "MRProgress", "AFIncrementalStore"]
  # end
  # it 'will find AFNetworking at the first position if exact - with positive popularity sorting' do
  #   first_three_names_for_search('name:AFNetworking', sort: 'popularity').should == %w(AFNetworking RestKit Nimbus)
  # end
  # it 'will find AFNetworking at the first position if exact - with name sorting' do
  #   first_three_names_for_search('name:AFNetworking', sort: 'name').should == ["AFNetworking", "AFIncrementalStore", "MRProgress"]
  # end
  # it 'will find AFNetworking even if searched in a strange way' do
  #   first_three_names_for_search('name:AfNeTwOrKiNg', sort: '-popularity').should == ["AFNetworking", "MRProgress", "AFIncrementalStore"]
  # end
  
  it 'will find ObjectiveRecord via CoreData' do
    first_three_names_for_search('CoreData', sort: 'name').should == ["AFIncrementalStore", "MagicalRecord", "PonyDebugger"]
  end

  it 'will survive searching ORed' do
    first_three_names_for_search('ios|osx', sort: 'name').should == %w(AFIncrementalStore AFNetworking AMScrollingNavbar)
  end

  it 'will default to popularity with unrecognized sort orders' do
    first_three_names_for_search('a', sort: 'quack').should == %w(AFNetworking TYPFontAwesome Alamofire)
  end

  # This case is removed as there are two versions: 0.1 and 0.1.0 – and they are different.
  # it 'will not find EGOTableViewPullRefresh if on:osx is specified (it is ios only)' do
  #   special_cases.search('on:osx EGOTableViewPullRefresh', sort: 'name').include?('EGOTableViewPullRefresh').should == false
  # end

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

  def with_pod_added(name, &block)
    pod = Pod.all { |pods| pods.where(name: name) }.first
    Search.instance.replace(pod, Pods.instance)

    block.call(pod)

    Search.instance.remove(pod.id)
  end

  def find(name)
    with_pod_added(name) do |_pod|
      special_cases.search(name, sort: 'name').should == [name]
      special_cases.search('Kyle Fuller', sort: 'name').should == [name]
    end
  end

  describe "will find Kyle's beloved pods" do
    [
      'QueryKit',
      'Stencil',
      'CGFloatType',
      'URITemplate',
      'PathKit',
      'ReactiveQueryKit',
      'Expecta+ReactiveCocoa',
      'NSAttributedString+CCLFormat',
      'CCLDefaults',
      'CCLHTTPServer',
      'KFData',
    ].each do |name|
      it "finds #{name}" do
        find(name)
      end
    end
  end

end
