# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'rack/test'

describe 'Facets Integration Tests' do

  extend Rack::Test::Methods

  def app
    CocoapodSearch
  end

  ok do
    get '/api/v1/pods.facets.json', {}
    result = Yajl.load(last_response.body)
    result['platform'].keys.sort.should == %w(ios osx watchos)
    result['tags'].keys.sort.should == ["alert", "analytics", "api", "button", "client", "communication", "controller", "http", "image", "json", "kit", "layout", "logging", "navigation", "network", "notification", "parser", "progress", "rest", "table", "test", "text", "view", "xml"]
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform'
    result = Yajl.load(last_response.body)
    result['platform'].keys.sort.should == %w(ios osx watchos)
    result['tags'].should.nil?
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform', counts: 'false'
    result = Yajl.load(last_response.body)
    result['platform'].sort.should == %w(ios osx watchos).sort
  end

  ok do
    get '/api/v1/pods.facets.json',  except: 'tags'
    result = Yajl.load(last_response.body)
    result['platform'].keys.sort.should == %w(ios osx watchos)
    result['tags'].should.nil?
  end

  ok do # If we filter, we get (generally) less than if we don't.
    get '/api/v1/pods.facets.json',  only: 'platform', filter: 'mattt'
    filtered_result = Yajl.load(last_response.body)
    get '/api/v1/pods.facets.json',  only: 'platform'
    result = Yajl.load(last_response.body)

    filtered_platforms = filtered_result['platform']
    platforms = result['platform']
    platforms.keys.each do |key|
      filtered_platforms[key].should < platforms[key]
    end
  end

  ok do
    get '/api/v1/pods.facets.json',  only: %w(platform name), include: 'name', filter: 'author:mattt'
    result = Yajl.load(last_response.body)
    result['platform'].keys.sort.should == %w(ios osx watchos)
    result['name'].keys.sort.should == ["af", "afincrementalstore", "afnetworking", "attributed", "attributedlabel", "formatter", "formatterkit", "incremental", "incrementalstore", "kit", "label", "networking", "store", "ttt", "tttattributedlabel"]
    result['tags'].should.nil?
  end

  ok do
    get '/api/v1/pods.facets.json',  include: 'version', filter: 'mattt'
    result = Yajl.load(last_response.body)
    result['version'].keys.sort.first(3).should == ["0.1.0", "0.10.0", "0.10.1"]
  end

  # ok do
  #   get '/api/v1/pods.facets.json', { only: 'id', include: 'id', filter: 'author:kyle' }
  #   Yajl.load(last_response.body).should == {"platform"=>{"ios"=>318, "osx"=>109}}
  # end

end
