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
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>317, "osx"=>109}, "tags"=>{"serialization"=>3, "json"=>10, "view"=>43, "controller"=>23, "button"=>5, "notification"=>3, "image"=>15, "communication"=>1, "api"=>16, "table"=>6, "http"=>7, "progress"=>4, "layout"=>4, "network"=>5, "alert"=>3, "test"=>2, "manager"=>4, "navigation"=>5, "rest"=>3, "picker"=>4, "client"=>8, "logging"=>7, "parser"=>3, "xml"=>1, "authentication"=>1, "gesture"=>3, "text"=>2, "analytics"=>1}}
  end
  
  ok do
    get '/api/v1/pods.facets.json', { only: 'platform' }
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>317, "osx"=>109}}
  end
  
  ok do
    get '/api/v1/pods.facets.json', { only: 'platform', counts: 'false' }
    Yajl.load(last_response.body).should == {"platform"=>["ios", "osx"]}
  end
  
  ok do
    get '/api/v1/pods.facets.json', { except: 'tags' }
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>317, "osx"=>109}}
  end
  
  ok do
    get '/api/v1/pods.facets.json', { only: 'platform', filter: 'kyle' }
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>2, "osx"=>1}}
  end
  
  ok do
    get '/api/v1/pods.facets.json', { only: ['platform', 'name'], include: 'name', filter: 'author:kyle' }
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>2, "osx"=>1}, "name"=>{"view"=>1, "grid"=>1, "kf"=>1, "kfdata"=>1, "data"=>1, "kkgridview"=>1, "kk"=>1, "gridview"=>1}}
  end
  
  ok do
    get '/api/v1/pods.facets.json', { include: 'version', filter: 'kyle' }
    Yajl.load(last_response.body).should == {"platform"=>{"ios"=>2, "osx"=>1}, "tags"=>{}, "version"=>{"0.0.1"=>1, "0.4"=>1, "0.3"=>1, "0.6.8.2"=>1}}
  end
  
  # ok do
  #   get '/api/v1/pods.facets.json', { only: 'id', include: 'id', filter: 'author:kyle' }
  #   Yajl.load(last_response.body).should == {"platform"=>{"ios"=>318, "osx"=>109}}
  # end

end
