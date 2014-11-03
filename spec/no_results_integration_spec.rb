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
    Yajl.load(no_results.send_search)['tag'].should == {"network"=>2, "rest"=>1, "image"=>6, "http"=>2, "json"=>5, "progress"=>2, "parser"=>4, "logging"=>1, "view"=>18, "controller"=>9, "client"=>3, "test"=>7, "api"=>7, "navigation"=>4, "button"=>2, "kit"=>1, "notification"=>2, "communication"=>1, "table"=>4, "text"=>3, "serialization"=>1, "layout"=>1, "widget"=>1, "xml"=>1, "manager"=>1, "analytics"=>1, "authentication"=>1}
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
