# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the Picky style API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do
    
  def pod_ids
    @pod_ids ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.picky.ids.json'
  end
  
  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.picky.hash.json'
  end

  # Testing a count of results.
  #
  ok { pods.search('LoremIpsum').ids.should == ['LoremIpsum'] }
  
end
