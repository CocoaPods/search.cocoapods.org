# coding: utf-8
#
require 'spec_helper'
require 'rack/test'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Search Integration Tests' do
  include Rack::Test::Methods
  
  before(:all) do
    Picky::Indexes.index
    Picky::Indexes.load
    CocoapodSearch.prepare # Needed to load the data for the rendered search results.
  end
  
  def app
    CocoapodSearch
  end

  [:picky, :flat].each do |structure|
    [:hash, :ids].each do |item_format|
      it "returns information on the API" do
        options "/api/v2.0/pods.#{structure}.#{item_format}.json"
    
        last_response.body.should == "{\"GET\":{\"description\":\"Perform a query and receive a JSON #{structure} result with result items formatted as #{item_format}.\",\"parameters\":{\"query\":{\"type\":\"string\",\"description\":\"The search query. All Picky special characters are allowed and used.\",\"required\":true},\"ids\":{\"type\":\"integer\",\"description\":\"How many result ids and items should be returned with the result.\",\"required\":false,\"default\":20},\"offset\":{\"type\":\"integer\",\"description\":\"At what position the query results should start.\",\"required\":false,\"default\":0}},\"example\":{\"query\":\"af networking\",\"ids\":50,\"offset\":0}}}"
      end
    end
  end

end
