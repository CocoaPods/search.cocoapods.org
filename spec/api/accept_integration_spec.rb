# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'rack/test'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Accept Integration Tests' do

  def app
    CocoapodSearch
  end

  describe 'expected successes' do
    extend Rack::Test::Methods

    query                  = 'a'
    expected_results       = 20
    expected_total_results = 55

    [
      # Convenience.
      #
      ['/api/v1/pods.picky.hash.json', { query: query }],
      ['/api/v1/pods.picky.ids.json',  { query: query }],
      ['/api/v1/pods.flat.hash.json',  { query: query }],
      ['/api/v1/pods.flat.ids.json',   { query: query }],

      # Defaults.
      #
      ['/api/pods', { query: query }, {}],
      ['/api/pods', { query: query }, {}],
      ['/api/pods', { query: query }, {}],
      ['/api/pods', { query: query }, {}],

      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'text/json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'text/json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'text/json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'text/json' }],

      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/json' }],

      # Latest version.
      #
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.hash.json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.ids.json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+flat.hash.json' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+flat.ids.json' }],

      # Versions.
      #
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.hash.json; version=1' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.ids.json; version=1' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+flat.hash.json; version=1' }],
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+flat.ids.json; version=1' }],
    ].each do |params|
      it 'returns information on the API' do
        get(*params)

        last_response.status.should == 200
        last_response.content_type.should == 'application/json;charset=utf-8'

        # If there is "flat" in there, check the resulting array size.
        #
        case params.first + (params.last['HTTP_ACCEPT'] || '')
        when /flat/
          Yajl::Parser.parse(last_response.body).size.should == expected_results
        else
          Yajl::Parser.parse(last_response.body)['total'].should == expected_total_results
        end
      end
    end
  end

  describe 'expected failures' do
    extend Rack::Test::Methods

    query = 'test'

    [
      # Wrong URL.
      #
      ['/api/v1/pods.picky.hash.jsn', { query: query }],
      ['/api/v1/pods.picky.json',  { query: query }],
      ['/api/v1/pods.hash.json',  { query: query }],
      ['/api/v0/pods.flat.ids.json',   { query: query }],
    ].each do |params|
      it 'returns information on the API' do
        get(*params)

        last_response.status.should == 404
      end
    end

    [
      # Wrong Accept.
      #
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'txt/json' }],
      ['/api/pods',  { query: query }, { 'HTTP_ACCEPT' => 'txt/json' }],
      ['/api/pods',  { query: query }, { 'HTTP_ACCEPT' => 'txt/json' }],
      ['/api/pods',   { query: query }, { 'HTTP_ACCEPT' => 'txt/json' }],

      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/jsn' }],
      ['/api/pods',  { query: query }, { 'HTTP_ACCEPT' => 'application/jsn' }],
      ['/api/pods',  { query: query }, { 'HTTP_ACCEPT' => 'application/jsn' }],
      ['/api/pods',   { query: query }, { 'HTTP_ACCEPT' => 'application/jsn' }],

      # Wrong version in Accept.
      #
      ['/api/pods', { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.hash.json; version=0' }],
      ['/api/pods',  { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.hash.json; version=1.0' }],
      ['/api/pods',  { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.hash.json; version=0.9-beta' }],
      ['/api/pods',   { query: query }, { 'HTTP_ACCEPT' => 'application/vnd.cocoapods.org+picky.hash.json; version=1.0.1' }],
    ].each do |params|
      it 'returns information on the API' do
        get(*params)

        last_response.status.should == 406
      end
    end
  end

end
