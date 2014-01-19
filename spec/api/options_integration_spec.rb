# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'rack/test'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Search Integration Tests' do
  extend Rack::Test::Methods
  
  def app
    CocoapodSearch
  end

  [:picky, :flat].each do |structure|
    [:hash, :ids].each do |item_structure|
      it "returns information on the API" do
        options "/api/v1/pods.#{structure}.#{item_structure}.json"
    
        last_response.body.should == "{\"GET\":{\"description\":\"Perform a query and receive a #{structure} JSON result with result items formatted as #{item_structure}.\",\"parameters\":{\"query\":{\"type\":\"string\",\"description\":\"The search query. All Picky special characters are allowed and used.\",\"required\":true},\"ids\":{\"type\":\"integer\",\"description\":\"How many result ids and items should be returned with the result.\",\"required\":false,\"default\":20},\"offset\":{\"type\":\"integer\",\"description\":\"At what position the query results should start.\",\"required\":false,\"default\":0}},\"example\":{\"query\":\"af networking\",\"ids\":50,\"offset\":0}}}"
      end
    end
  end

end
