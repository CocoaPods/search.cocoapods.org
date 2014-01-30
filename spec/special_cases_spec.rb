# coding: utf-8
#
require File.expand_path '../spec_helper', __FILE__
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Special Cases' do
  
  def special_cases
    Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.flat.ids.json'
  end
  
  it 'will correctly find _.m' do
    special_cases.search('_.m').should == ['_.m']
  end
  it 'will correctly find JSONKit' do
    special_cases.search('JSONKit very high library').should == ['JSONKit']
  end

end
