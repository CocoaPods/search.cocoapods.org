# coding: utf-8
#
require File.expand_path '../spec_helper', __FILE__
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do
  
  def no_results
    @no_results ||= Picky::TestClient.new CocoapodSearch, :path => '/no_results.json'
  end
  
  it 'will return the right tag facets' do
    Yajl.load(no_results.send_search)["tag"].should == {"api"=>241, "image"=>206, "view"=>516, "button"=>85, "controller"=>173, "layout"=>69, "manager"=>43, "test"=>102, "text"=>99, "table"=>61, "navigation"=>42, "progress"=>71, "http"=>79, "network"=>55, "logging"=>32, "json"=>91, "client"=>111, "xml"=>40, "authentication"=>14, "picker"=>58, "gesture"=>30, "alert"=>24, "rest"=>44, "notification"=>54, "analytics"=>35, "communication"=>10, "password"=>11, "serialization"=>6, "kit"=>17, "payment"=>8, "parser"=>43, "widget"=>8}
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: "meow"))["split"].should == [[], 0]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: "libcomponentlogging"))["split"].should == [["lib", "component", "logging"], 23]
  end

end
