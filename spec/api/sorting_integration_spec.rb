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

  def first_three_names_for_search(query, options = {})
    pods.search(query, options).first(3)
  end

  ok { first_three_names_for_search('on:osx mattt', sort: 'name').should == %w(AFIncrementalStore AFNetworking CargoBay) }

  ok { first_three_names_for_search('on:osx mattt', sort: 'popularity').should ==  %w(AFNetworking FormatterKit AFIncrementalStore) }
  ok { first_three_names_for_search('on:osx mattt', sort: '-popularity').should == %w(GroundControl CargoBay AFIncrementalStore) }
  
  ok { first_three_names_for_search('on:osx mattt', sort: 'quality').should ==  %w(AFNetworking FormatterKit AFIncrementalStore) }
  ok { first_three_names_for_search('on:osx mattt', sort: '-quality').should == %w(GroundControl CargoBay AFIncrementalStore) }

  ok { first_three_names_for_search('on:osx mattt', sort: 'watchers').should ==  %w(AFNetworking AFIncrementalStore FormatterKit) }
  ok { first_three_names_for_search('on:osx mattt', sort: '-watchers').should == %w(CargoBay GroundControl FormatterKit) }

  ok { first_three_names_for_search('on:osx mattt', sort: 'forks').should ==  %w(AFNetworking AFIncrementalStore FormatterKit) }
  ok { first_three_names_for_search('on:osx mattt', sort: '-forks').should == %w(GroundControl CargoBay FormatterKit) }

  ok { first_three_names_for_search('on:osx mattt', sort: 'stars').should ==  %w(AFNetworking FormatterKit AFIncrementalStore) }
  ok { first_three_names_for_search('on:osx mattt', sort: '-stars').should == %w(CargoBay GroundControl AFIncrementalStore) }

  ok { first_three_names_for_search('on:osx mattt', sort: 'contributors').should ==  %w(AFNetworking FormatterKit AFIncrementalStore) }
  ok { first_three_names_for_search('on:osx mattt', sort: '-contributors').should == %w(GroundControl CargoBay AFIncrementalStore) }

end
