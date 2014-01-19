# coding: utf-8
#
require File.expand_path '../spec_helper', __FILE__
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do
  
  def no_results
    Picky::TestClient.new CocoapodSearch, :path => '/no_results.json'
  end
  
  it 'will return the right tag facets' do
    Yajl.load(no_results.send_search)["tag"].should == {
      "serialization" => 3,
      "json" => 10,
      "notification" => 3,
      "communication" => 1,
      "api" => 16,
      "http" => 7,
      "network" => 5,
      "test" => 2,
      "rest" => 3,
      "logging" => 7,
      "parser" => 3,
      "xml" => 1,
      "authentication" => 1,
      "gesture" => 3,
      "analytics" => 1
    }
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: "meow"))["split"].should == [[], 0]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: "libcomponentlogging"))["split"].should == [["lib", "component", "logging"], 22]
  end

end
