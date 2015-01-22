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
    Yajl.load(no_results.send_search)['tag'].keys.sort.should == %w(analytics api button client communication controller http image json kit layout logging manager navigation network notification parser progress rest serialization table test text view widget xml)
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'meow'))['split'].should == [[], 0]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'afnetworking'))['split'].should == [['networking'], 4]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'groundcontrol'))['split'].should == [%w(ground control), 1]
  end

end
