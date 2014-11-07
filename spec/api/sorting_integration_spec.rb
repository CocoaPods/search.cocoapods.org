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

  ok { pods.search('on:osx mattt', sort: 'name').should == %w(AFIncrementalStore AFNetworking CargoBay GroundControl) }

  ok { pods.search('on:osx mattt', sort: 'popularity').should ==  %w(AFNetworking AFIncrementalStore CargoBay GroundControl) }
  ok { pods.search('on:osx mattt', sort: '-popularity').should == %w(GroundControl CargoBay AFIncrementalStore AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'watchers').should ==  %w(AFNetworking AFIncrementalStore GroundControl CargoBay) }
  ok { pods.search('on:osx mattt', sort: '-watchers').should == %w(CargoBay GroundControl AFIncrementalStore AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'forks').should ==  %w(AFNetworking AFIncrementalStore CargoBay GroundControl) }
  ok { pods.search('on:osx mattt', sort: '-forks').should == %w(GroundControl CargoBay AFIncrementalStore AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'stars').should ==  %w(AFNetworking AFIncrementalStore GroundControl CargoBay) }
  ok { pods.search('on:osx mattt', sort: '-stars').should == %w(CargoBay GroundControl AFIncrementalStore AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'contributors').should ==  %w(AFNetworking AFIncrementalStore CargoBay GroundControl) }
  ok { pods.search('on:osx mattt', sort: '-contributors').should == %w(GroundControl CargoBay AFIncrementalStore AFNetworking) }

end
