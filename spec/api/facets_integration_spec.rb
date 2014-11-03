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
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>168, "osx"=>42}, "tags"=>{"network"=>3, "rest"=>1, "image"=>5, "http"=>5, "json"=>5, "progress"=>4, "parser"=>4, "logging"=>1, "view"=>25, "controller"=>9, "client"=>2, "test"=>6, "button"=>2, "navigation"=>4, "notification"=>5, "table"=>6, "api"=>6, "kit"=>1, "text"=>1, "widget"=>1, "serialization"=>1, "xml"=>2, "manager"=>3, "layout"=>2}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>168, "osx"=>42}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform', counts: 'false'
    Yajl.load(last_response.body).should == { 'platform' => %w(ios osx) }
  end

  ok do
    get '/api/v1/pods.facets.json',  except: 'tags'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>168, "osx"=>42}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform', filter: 'mattt'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>6, "osx"=>5}}
  end

  ok do
    get '/api/v1/pods.facets.json',  only: %w(platform name), include: 'name', filter: 'author:mattt'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>6, "osx"=>5}, "name"=>{"afnetworking"=>1, "af"=>2, "networking"=>1, "kit"=>1, "tttattributedlabel"=>1, "ttt"=>1, "attributedlabel"=>1, "attributed"=>1, "label"=>1, "formatterkit"=>1, "formatter"=>1, "afincrementalstore"=>1, "incrementalstore"=>1, "incremental"=>1, "store"=>1, "control"=>1, "groundcontrol"=>1, "ground"=>1, "cargobay"=>1, "cargo"=>1, "bay"=>1, "ono"=>1}}
  end

  ok do
    get '/api/v1/pods.facets.json',  include: 'version', filter: 'mattt'
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>6, "osx"=>5}, "tags"=>{"network"=>1, "xml"=>1}, "version"=>{"2.3.0"=>1, "0.9.0"=>1, "2.2.1"=>1, "0.10.1"=>1, "2.0.3"=>2, "1.0rc2"=>1, "2.1.0"=>3, "1.0"=>1, "2.0.0"=>3, "rc3"=>1, "1.3.0"=>3, "2.3.1"=>1, "0.10.0"=>2, "1.3.4"=>1, "1.0rc3"=>1, "2.2.4"=>1, "1.3.1"=>2, "2.0.1"=>3, "1.1.1"=>3, "0.7.0"=>2, "2.2.0"=>1, "1.0.1"=>3, "2.2.2"=>1, "rc1"=>1, "2.0.2"=>2, "1.3.2"=>2, "2.2.3"=>1, "1.0rc1"=>1, "1.3.3"=>1, "rc2"=>1, "0.9.2"=>1, "1.2.0"=>3, "0.5.1"=>2, "1.2.1"=>3, "0.9.1"=>1, "1.1.0"=>4, "1.0.0"=>4, "0.0.2"=>2, "0.1.0"=>2, "0.0.1"=>2, "1.8.0"=>1, "1.8.1"=>1, "1.5.0"=>2, "1.7.1"=>1, "1.7.0"=>1, "1.7.2"=>1, "1.9.4"=>1, "1.9.5"=>1, "0.6.0"=>1, "1.4.0"=>2, "0.5.0"=>1, "1.6.0"=>1, "1.5.1"=>2, "1.4.2"=>1, "1.6.4"=>1, "1.2.2"=>1, "1.6.3"=>1, "1.9.0"=>1, "1.6.1"=>1, "1.6.2"=>1, "1.7.4"=>1, "0.3.1"=>2, "0.2.1"=>1, "0.3.0"=>2, "0.0.4"=>1, "0.0.3"=>1, "0.0.5"=>1, "0.3.2"=>2, "0.4.0"=>1, "0.3.3"=>1, "0.2.0"=>1, "1.9.2"=>1, "1.7.3"=>1, "1.9.3"=>1, "1.10.0"=>1, "1.9.1"=>1, "1.7.5"=>1, "1.4.1"=>2, "1.10.1"=>1, "1.4.3"=>1, "1.1.2"=>1, "0.4.1"=>1}}
  end

  # ok do
  #   get '/api/v1/pods.facets.json', { only: 'id', include: 'id', filter: 'author:kyle' }
  #   Yajl.load(last_response.body).should == {"platform"=>{"ios"=>318, "osx"=>109}}
  # end

end
