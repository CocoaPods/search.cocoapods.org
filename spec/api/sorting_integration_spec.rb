# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Sorting Integration Tests' do
  
  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.ids.json'
  end
  
  ok { pods.search('on:osx mattt', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "CargoBay", "GroundControl"] }
  
  ok { pods.search('on:osx mattt', sort: 'popularity').should ==  ["AFNetworking", "AFIncrementalStore", "CargoBay", "GroundControl"] }
  ok { pods.search('on:osx mattt', sort: '-popularity').should == ["GroundControl", "CargoBay", "AFIncrementalStore", "AFNetworking"] }
  
  ok { pods.search('on:osx mattt', sort: 'watchers').should ==  ["AFNetworking", "AFIncrementalStore", "GroundControl", "CargoBay"] }
  ok { pods.search('on:osx mattt', sort: '-watchers').should == ["CargoBay", "GroundControl", "AFIncrementalStore", "AFNetworking"] }
  
  ok { pods.search('on:osx mattt', sort: 'forks').should ==  ["AFNetworking", "AFIncrementalStore", "CargoBay", "GroundControl"] }
  ok { pods.search('on:osx mattt', sort: '-forks').should == ["GroundControl", "CargoBay", "AFIncrementalStore", "AFNetworking"] }
  
  ok { pods.search('on:osx mattt', sort: 'stars').should ==  ["AFNetworking", "AFIncrementalStore", "GroundControl", "CargoBay"] }
  ok { pods.search('on:osx mattt', sort: '-stars').should == ["CargoBay", "GroundControl", "AFIncrementalStore", "AFNetworking"] }
  
  ok { pods.search('on:osx mattt', sort: 'contributors').should ==  ["AFNetworking", "AFIncrementalStore", "CargoBay", "GroundControl"] }
  ok { pods.search('on:osx mattt', sort: '-contributors').should == ["GroundControl", "CargoBay", "AFIncrementalStore", "AFNetworking"] }

end
