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

  ok { pods.search('on:osx mattt', sort: 'name').should == %w(AFIncrementalStore AFNetworking AFOAuth2Client CargoBay FormatterKit GroundControl) }

  ok { pods.search('on:osx mattt', sort: 'popularity').should ==  %w(AFNetworking AFIncrementalStore FormatterKit CargoBay GroundControl AFOAuth2Client) }
  ok { pods.search('on:osx mattt', sort: '-popularity').should == %w(AFOAuth2Client GroundControl CargoBay FormatterKit AFIncrementalStore AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'watchers').should ==  %w(AFNetworking AFIncrementalStore GroundControl FormatterKit CargoBay AFOAuth2Client) }
  ok { pods.search('on:osx mattt', sort: '-watchers').should == %w(AFOAuth2Client CargoBay FormatterKit GroundControl AFIncrementalStore AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'forks').should ==  %w(AFNetworking AFIncrementalStore FormatterKit AFOAuth2Client CargoBay GroundControl) }
  ok { pods.search('on:osx mattt', sort: '-forks').should == %w(GroundControl CargoBay AFOAuth2Client FormatterKit AFIncrementalStore AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'stars').should ==  %w(AFNetworking FormatterKit AFIncrementalStore GroundControl CargoBay AFOAuth2Client) }
  ok { pods.search('on:osx mattt', sort: '-stars').should == %w(AFOAuth2Client CargoBay GroundControl AFIncrementalStore FormatterKit AFNetworking) }

  ok { pods.search('on:osx mattt', sort: 'contributors').should ==  %w(AFNetworking AFIncrementalStore FormatterKit CargoBay AFOAuth2Client GroundControl) }
  ok { pods.search('on:osx mattt', sort: '-contributors').should == %w(GroundControl AFOAuth2Client CargoBay FormatterKit AFIncrementalStore AFNetworking) }

end
