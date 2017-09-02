# coding: utf-8
# frozen_string_literal: true
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

  ok { first_three_names_for_search('on:osx mattt', sort: 'name').should == ["AFNetworking", "FormatterKit"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'popularity').should ==  ["AFNetworking", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-popularity').should == ["FormatterKit", "AFNetworking"] }
  
  ok { first_three_names_for_search('on:osx mattt', sort: 'quality').should ==  ["FormatterKit", "AFNetworking"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-quality').should == ["FormatterKit", "AFNetworking"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'watchers').should ==  ["AFNetworking", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-watchers').should == ["FormatterKit", "AFNetworking"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'forks').should ==  ["AFNetworking", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-forks').should == [ "FormatterKit", "AFNetworking"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'stars').should ==  ["AFNetworking", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-stars').should == ["FormatterKit", "AFNetworking"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'contributors').should ==  ["AFNetworking", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-contributors').should == ["FormatterKit", "AFNetworking"] }

end
