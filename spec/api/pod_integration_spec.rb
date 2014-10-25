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
    get "/api/v1/pod/_.m.json"
    
    last_response.status.should == 200
    last_response.body.should == "{\"id\":\"_.m\",\"platforms\":[\"ios\",\"osx\"],\"version\":\"0.1.2\",\"summary\":\"_.m is a port of Underscore.jsto Objective-C.\",\"authors\":{\"Kevin Malakoff\":\"kmalakoff@gmail.com\"},\"link\":\"http://kmalakoff.github.com/_.m/\",\"source\":{\"git\":\"https://github.com/kmalakoff/_.m.git\",\"tag\":\"0.1.2\"},\"subspecs\":[],\"tags\":[]}"
  end

end
