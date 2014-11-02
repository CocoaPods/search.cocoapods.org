# coding: utf-8
#
require File.expand_path '../spec_helper', __FILE__
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do

  def no_results
    @no_results ||= Picky::TestClient.new CocoapodSearch, path: '/no_results.json'
  end

  it 'will return the right tag facets' do
    Yajl.load(no_results.send_search)['tag'].should == {"api"=>4, "image"=>5, "view"=>8, "button"=>3, "controller"=>3, "layout"=>1, "manager"=>3, "test"=>2, "text"=>1, "table"=>1, "navigation"=>1, "progress"=>2, "http"=>5, "network"=>3, "logging"=>2, "json"=>3, "client"=>1, "xml"=>3}
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'meow'))['split'].should == [[], 0]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'afnetworking'))['split'].should == [["networking"], 10]
  end

end
