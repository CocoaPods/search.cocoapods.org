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
    Yajl.load(last_response.body).should == { 'platform' => { 'ios' => 4709, 'osx' => 834 }, 'tags' => { 'api' => 241, 'image' => 206, 'view' => 516, 'button' => 85, 'controller' => 173, 'layout' => 69, 'manager' => 43, 'test' => 102, 'text' => 99, 'table' => 61, 'navigation' => 42, 'progress' => 71, 'http' => 79, 'network' => 55, 'logging' => 32, 'json' => 91, 'client' => 111, 'xml' => 40, 'authentication' => 14, 'picker' => 58, 'gesture' => 30, 'alert' => 24, 'rest' => 44, 'notification' => 54, 'analytics' => 35, 'communication' => 10, 'password' => 11, 'serialization' => 6, 'kit' => 17, 'payment' => 8, 'parser' => 43, 'widget' => 8 } }
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform'
    Yajl.load(last_response.body).should == { 'platform' => { 'ios' => 4709, 'osx' => 834 } }
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform', counts: 'false'
    Yajl.load(last_response.body).should == { 'platform' => %w(ios osx) }
  end

  ok do
    get '/api/v1/pods.facets.json',  except: 'tags'
    Yajl.load(last_response.body).should == { 'platform' => { 'ios' => 4709, 'osx' => 834 } }
  end

  ok do
    get '/api/v1/pods.facets.json',  only: 'platform', filter: 'kyle'
    Yajl.load(last_response.body).should == { 'platform' => { 'ios' => 16, 'osx' => 6 } }
  end

  ok do
    get '/api/v1/pods.facets.json',  only: %w(platform name), include: 'name', filter: 'author:kyle'
    Yajl.load(last_response.body).should == { 'platform' => { 'ios' => 16, 'osx' => 6 }, 'name' => { 'ios' => 1, 'storyboard' => 1, 'segue' => 1, 'table' => 1, 'view' => 3, 'scroll' => 1, 'image' => 2, 'pull' => 2, 'color' => 1, 'kit' => 2, 'data' => 1, 'button' => 1, 'sdk' => 1, 'down' => 1, 'imagedownloader' => 1, 'downloader' => 2, 'async' => 2, 'browser' => 1, 'flow' => 1, 'attributed' => 1, 'page' => 1, 'countdowntimer' => 1, 'timer' => 1, 'flat' => 1, 'web' => 1, 'push' => 1, 'osx' => 1, 'format' => 1, 'asyncimagedownloader' => 1, 'asyncimagedownloaderosx' => 1, 'imagedownloaderosx' => 1, 'drag' => 2, 'coding' => 1, 'ns' => 1, 'type' => 1, 'string' => 1, 'count' => 1, 'cclcolortransformer' => 1, 'ccl' => 2, 'colortransformer' => 1, 'transformer' => 2, 'ccldefaults' => 1, 'defaults' => 1, 'open' => 1, 'cgfloattype' => 1, 'cg' => 1, 'floattype' => 1, 'float' => 1, 'query' => 1, 'shared' => 1, 'expecta' => 1, 'expecta+comparison' => 1, 'comparison' => 1, 'flatbutton' => 1, 'kf' => 1, 'kfdata' => 1, 'khflatbutton' => 1, 'kh' => 1, 'kr' => 1, 'krkit' => 1, 'drupal' => 1, 'mf' => 2, 'mflcodingtransformer' => 1, 'mfl' => 1, 'codingtransformer' => 1, 'mfpageflowview' => 1, 'pageflowview' => 1, 'mfstoryboardpushsegue' => 1, 'storyboardpushsegue' => 1, 'mini' => 1, 'nsattributedstring+cclformat' => 1, 'attributedstring' => 1, 'nsattributedstring' => 1, 'cclformat' => 1, '+ccl' => 1, 'opensans' => 1, 'sans' => 1, 'querykit' => 1, 'ts' => 1, 'tsminiwebbrowser' => 1, 'miniwebbrowser' => 1, 'tsminiwebbrowser@kylerobson' => 1, 'kylerobson' => 2, 'zds_shared@kylerobson' => 1, 'zds_' => 1, 'zds_shared' => 1, 'zgcountdowntimer' => 1, 'zg' => 3, 'zgpulldragscrollview' => 1, 'pulldragscrollview' => 1, 'zgpulldragtableview' => 1, 'pulldragtableview' => 1, 'drupal-ios-sdk' => 1 } }
  end

  ok do
    get '/api/v1/pods.facets.json',  include: 'version', filter: 'kyle'
    Yajl.load(last_response.body).should == { 'platform' => { 'ios' => 16, 'osx' => 6 }, 'tags' => { 'image' => 2, 'view' => 1, 'controller' => 1, 'table' => 1, 'navigation' => 1 }, 'version' => { '1.0.2' => 2, '1.0.3' => 1, '1.0' => 3, '1.0.1' => 4, '2.0.0' => 1, '2.0.1' => 1, '2.0.2' => 1, '0.0.1' => 6, '0.1.0' => 1, '1.0.0' => 10, '1.1.1' => 1, '1.1.2' => 1, '0.0.2' => 2, '2.0.3' => 1, '2.0.4' => 1, '1.1' => 1, '0.0.3' => 2, '0.0.4' => 1, '0.3' => 1, '0.4.1' => 1, 'rc1' => 1, 'rc2' => 1, '0.4' => 1, '0.4.2' => 1, '0.8.0' => 1, '0.8.1' => 1 } }
  end

  # ok do
  #   get '/api/v1/pods.facets.json', { only: 'id', include: 'id', filter: 'author:kyle' }
  #   Yajl.load(last_response.body).should == {"platform"=>{"ios"=>318, "osx"=>109}}
  # end

end
