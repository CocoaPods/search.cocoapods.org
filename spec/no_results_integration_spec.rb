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
    Yajl.load(no_results.send_search)['tag'].should == {"network"=>3, "rest"=>1, "image"=>5, "http"=>5, "json"=>5, "progress"=>4, "parser"=>4, "logging"=>1, "view"=>25, "controller"=>9, "client"=>2, "test"=>6, "button"=>2, "navigation"=>4, "notification"=>5, "table"=>6, "api"=>6, "kit"=>1, "text"=>1, "widget"=>1, "serialization"=>1, "xml"=>2, "manager"=>3, "layout"=>2}
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'meow'))['split'].should == [[], 0]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'afnetworking'))['split'].should == [["networking"], 3]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'groundcontrol'))['split'].should == [["ground", "control"], 1]
  end

end
