# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Modifier Tests' do
  
  def pod_ids
    @pod_ids ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.picky.ids.json'
  end
  
  def first_three_names_for_search(query, options = {})
    pods.search(query, options).entries.map { |entry| entry[:id] }.first(3)
  end

  # Has been removed.
  #
  # The "text" gem used 20 MB itself, and the index used another 40 or so.
  # ok { pod_ids.search('afnutworking~').entries.first.should == 'AFNetworking' }
  
end
