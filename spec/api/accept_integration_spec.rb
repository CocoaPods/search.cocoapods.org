# coding: utf-8
#
require 'spec_helper'
require 'rack/test'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Search Integration Tests' do
  include Rack::Test::Methods
  
  before(:all) do
    Picky::Indexes.index
    Picky::Indexes.load
    CocoapodSearch.prepare # Needed to load the data for the rendered search results.
  end
  
  def app
    CocoapodSearch
  end

  describe 'expected successes' do
    query            = 'easy'
    expected_results = 12

    [
      # Convenience.
      #
      ["/api/v1/pods.picky.hash.json", { query: query }],
      ["/api/v1/pods.picky.ids.json",  { query: query }],
      ["/api/v1/pods.flat.hash.json",  { query: query }],
      ["/api/v1/pods.flat.ids.json",   { query: query }],
    
      # Defaults.
      #
      ["/api/pods", { query: query }, {}],
      ["/api/pods", { query: query }, {}],
      ["/api/pods", { query: query }, {}],
      ["/api/pods", { query: query }, {}],
    
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
    
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/json" }],

      # Latest version.
      #
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.hash.json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.ids.json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+flat.hash.json" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+flat.ids.json" }],
    
      # Versions.
      #
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.hash.json; version=1" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.ids.json; version=1" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+flat.hash.json; version=1" }],
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+flat.ids.json; version=1" }],
    ].each do |params|
      it "returns information on the API" do
        get *params
      
        last_response.should be_ok
      
        # If there is "flat" in there, check the resulting array size.
        #
        case params.first + (params.last['HTTP_ACCEPT'] || "")
        when %r{flat}
          Yajl::Parser.parse(last_response.body).size.should == expected_results
        else
          Yajl::Parser.parse(last_response.body)['total'].should == expected_results
        end
      end
    end
  end
  
  describe 'expected failures' do
    query = 'test'
    
    [
      # Wrong URL.
      #
      ["/api/v1/pods.picky.hash.jsn", { query: query }],
      ["/api/v1/pods.picky.json",  { query: query }],
      ["/api/v1/pods.hash.json",  { query: query }],
      ["/api/v0/pods.flat.ids.json",   { query: query }],
    ].each do |params|
      it "returns information on the API" do
        get *params
      
        last_response.should be_not_found
      end
    end
    
    [
      # Wrong Accept.
      #
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
      ["/api/pods",  { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
      ["/api/pods",  { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
      ["/api/pods",   { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
    
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
      ["/api/pods",  { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
      ["/api/pods",  { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
      ["/api/pods",   { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
    
      # Wrong version in Accept.
      #
      ["/api/pods", { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.hash.json; version=0" }],
      ["/api/pods",  { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.hash.json; version=1.0" }],
      ["/api/pods",  { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.hash.json; version=0.9-beta" }],
      ["/api/pods",   { query: query }, { 'HTTP_ACCEPT' => "application/vnd.cocoapods.org+picky.hash.json; version=1.0.1" }]
    ].each do |params|
      it "returns information on the API" do
        get *params
      
        last_response.status.should == 406
      end
    end
  end

end
