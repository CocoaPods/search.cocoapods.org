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
      ["/api/v2.0/pods.picky.hash.json", { query: query }],
      ["/api/v2.0/pods.picky.ids.json",  { query: query }],
      ["/api/v2.0/pods.flat.hash.json",  { query: query }],
      ["/api/v2.0/pods.flat.ids.json",   { query: query }],
    
      # Defaults.
      #
      ["/api/pods.picky.hash", { query: query }, {}],
      ["/api/pods.picky.ids",  { query: query }, {}],
      ["/api/pods.flat.hash",  { query: query }, {}],
      ["/api/pods.flat.ids",   { query: query }, {}],
    
      ["/api/pods.picky.hash", { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
      ["/api/pods.picky.ids",  { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
      ["/api/pods.flat.hash",  { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
      ["/api/pods.flat.ids",   { query: query }, { 'HTTP_ACCEPT' => "text/json" }],
    
      ["/api/pods.picky.hash", { query: query }, { 'HTTP_ACCEPT' => "application/json" }],
      ["/api/pods.picky.ids",  { query: query }, { 'HTTP_ACCEPT' => "application/json" }],
      ["/api/pods.flat.hash",  { query: query }, { 'HTTP_ACCEPT' => "application/json" }],
      ["/api/pods.flat.ids",   { query: query }, { 'HTTP_ACCEPT' => "application/json" }],
    
      # Versions.
      #
      ["/api/pods.picky.hash", { query: query }, { 'HTTP_ACCEPT' => "application/json; version=2" }],
      ["/api/pods.picky.ids",  { query: query }, { 'HTTP_ACCEPT' => "application/json; version=2" }],
      ["/api/pods.flat.hash",  { query: query }, { 'HTTP_ACCEPT' => "application/json; version=2" }],
      ["/api/pods.flat.ids",   { query: query }, { 'HTTP_ACCEPT' => "application/json; version=2" }]
    ].each do |params|
      it "returns information on the API" do
        get *params
      
        last_response.should be_ok
      
        case params.first
        when %r{.picky}
          Yajl::Parser.parse(last_response.body)['total'].should == expected_results
        else
          Yajl::Parser.parse(last_response.body).size.should == expected_results
        end
      end
    end
  end
  
  describe 'expected failures' do
    query = 'test'
    
    [
      # Wrong URL.
      #
      ["/api/v2.0/pods.picky.hash.jsn", { query: query }],
      ["/api/v2.0/pods.picky.json",  { query: query }],
      ["/api/v2.0/pods.hash.json",  { query: query }],
      ["/api/v0.0/pods.flat.ids.json",   { query: query }],
    ].each do |params|
      it "returns information on the API" do
        get *params
      
        last_response.should be_not_found
      end
    end
    
    [
      # Wrong Accept.
      #
      ["/api/pods.picky.hash", { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
      ["/api/pods.picky.ids",  { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
      ["/api/pods.flat.hash",  { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
      ["/api/pods.flat.ids",   { query: query }, { 'HTTP_ACCEPT' => "txt/json" }],
    
      ["/api/pods.picky.hash", { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
      ["/api/pods.picky.ids",  { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
      ["/api/pods.flat.hash",  { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
      ["/api/pods.flat.ids",   { query: query }, { 'HTTP_ACCEPT' => "application/jsn" }],
    
      # Wrong version in Accept.
      #
      ["/api/pods.picky.hash", { query: query }, { 'HTTP_ACCEPT' => "application/json; version=0" }],
      ["/api/pods.picky.ids",  { query: query }, { 'HTTP_ACCEPT' => "application/json; version=2.0" }],
      ["/api/pods.flat.hash",  { query: query }, { 'HTTP_ACCEPT' => "application/json; version=0.9-beta" }],
      ["/api/pods.flat.ids",   { query: query }, { 'HTTP_ACCEPT' => "application/json; version=2.0.1" }]
    ].each do |params|
      it "returns information on the API" do
        get *params
      
        last_response.status.should == 406
      end
    end
  end

end
