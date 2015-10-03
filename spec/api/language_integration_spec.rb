# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Language Filtering Integration Tests' do

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.ids.json'
  end

  def first_five_names_for_search(query, options = {})
    pods.search(query, options).first(5)
  end

  # Control.
  ok { first_five_names_for_search('name:a', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "AMScrollingNavbar", "AQGridView", "ARAnalytics"] }
  
  # Language filters.
  ok { first_five_names_for_search('language:swift', sort: 'name').should == ["AMScrollingNavbar", "Alamofire", "Cartography", "Cent", "Charts"] }
  ok { first_five_names_for_search('language:objc', sort: 'name').should == ["AFIncrementalStore", "AFNetworking", "AQGridView", "ARAnalytics", "ASIHTTPRequest"] }

end
