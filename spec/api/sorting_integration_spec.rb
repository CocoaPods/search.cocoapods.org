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

  ok { first_three_names_for_search('on:osx mattt', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "Alamofire"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'popularity').should ==  ["AFNetworking", "Alamofire", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-popularity').should == ["AFIncrementalStore", "FormatterKit", "Alamofire"] }
  
  ok { first_three_names_for_search('on:osx mattt', sort: 'quality').should ==  ["AFNetworking", "FormatterKit", "Alamofire"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-quality').should == ["AFIncrementalStore", "Alamofire", "FormatterKit"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'watchers').should ==  ["AFNetworking", "Alamofire", "AFIncrementalStore"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-watchers').should == ["FormatterKit", "AFIncrementalStore", "Alamofire"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'forks').should ==  ["AFNetworking", "Alamofire", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-forks').should == ["AFIncrementalStore", "FormatterKit", "Alamofire"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'stars').should ==  ["AFNetworking", "Alamofire", "FormatterKit"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-stars').should == ["AFIncrementalStore", "FormatterKit", "Alamofire"] }

  ok { first_three_names_for_search('on:osx mattt', sort: 'contributors').should ==  ["AFNetworking", "FormatterKit", "AFIncrementalStore"] }
  ok { first_three_names_for_search('on:osx mattt', sort: '-contributors').should == ["Alamofire", "AFIncrementalStore", "FormatterKit"] }

end
