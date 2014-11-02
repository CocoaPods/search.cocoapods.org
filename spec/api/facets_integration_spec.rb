# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'rack/test'

describe 'Search Integration Tests' do

  extend Rack::Test::Methods

  def app
    CocoapodSearch
  end

  ok do
    get '/api/v1/pods.facets.json', {}
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>87, "osx"=>23}, "tags"=>{"api"=>4, "image"=>5, "view"=>8, "button"=>3, "controller"=>3, "layout"=>1, "manager"=>3, "test"=>2, "text"=>1, "table"=>1, "navigation"=>1, "progress"=>2, "http"=>5, "network"=>3, "logging"=>2, "json"=>3, "client"=>1, "xml"=>3}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>87, "osx"=>23}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform', counts: 'false'
    Yajl.load(last_response.body).should == { 'platform' => %w(ios osx) }
  end

  ok do
    get '/api/v1/pods.facets.json',  except: 'tags'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>87, "osx"=>23}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform', filter: 'mattt'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>8, "osx"=>7}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: %w(platform name), include: 'name', filter: 'author:mattt'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>8, "osx"=>7}, "name"=>{"activity"=>1, "image"=>1, "request"=>3, "core"=>1, "network"=>1, "af"=>7, "client"=>1, "operation"=>3, "afcoreimageresponseserializer"=>1, "coreimageresponseserializer"=>1, "response"=>1, "serializer"=>1, "afhttp"=>1, "logger"=>2, "afhttprequestoperationlogger"=>1, "requestoperationlogger"=>1, "afincrementalstore"=>1, "incrementalstore"=>1, "incremental"=>1, "store"=>1, "afjsonrpcclient"=>1, "afjsonrpc"=>1, "afkissxmlrequestoperation"=>2, "kissxmlrequestoperation"=>2, "kiss"=>2, "xml"=>2, "afkissxmlrequestoperation@aceontech"=>1, "aceontech"=>1, "afmsgpackserialization"=>1, "msgpackserialization"=>1, "msg"=>1, "pack"=>1, "serialization"=>1, "afnetworkactivitylogger"=>1, "networkactivitylogger"=>1, "afnetworking"=>1, "networking"=>1}}
  end

  ok do
    get '/api/v1/pods.facets.json',  include: 'version', filter: 'mattt'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>8, "osx"=>7}, "tags"=>{"image"=>1, "http"=>1, "network"=>2, "logging"=>2, "json"=>1, "client"=>1, "xml"=>2}, "version"=>{"2.0.0"=>2, "2.0.1"=>2, "1.0"=>1, "1.0.1"=>1, "2.0.2"=>2, "0.0.1"=>3, "0.1.0"=>2, "1.0.0"=>2, "1.1.1"=>1, "1.2.0"=>1, "2.0.3"=>1, "1.2.1"=>1, "1.1.0"=>1, "0.9.2"=>1, "0.0.4"=>1, "1.3.0"=>1, "1.3.1"=>1, "2.1.0"=>1, "0.4.0"=>2, "0.3.0"=>2, "0.5.0"=>1, "0.9.0"=>2, "0.10.0"=>2, "0.3.2"=>1, "0.5.1"=>2, "0.3.1"=>2, "0.4.1"=>1, "2.3.0"=>1, "2.2.1"=>1, "0.10.1"=>1, "1.0rc2"=>1, "rc3"=>1, "2.3.1"=>1, "1.3.4"=>1, "1.0rc3"=>1, "2.2.4"=>1, "0.7.0"=>1, "2.2.0"=>1, "2.2.2"=>1, "rc1"=>1, "1.3.2"=>1, "2.2.3"=>1, "1.0rc1"=>1, "1.3.3"=>1, "rc2"=>1, "0.9.1"=>1}}
  end

  # ok do
  #   get '/api/v1/pods.facets.json', { only: 'id', include: 'id', filter: 'author:kyle' }
  #   Yajl.load(last_response.body).should == {"platform"=>{"ios"=>318, "osx"=>109}}
  # end

end
