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
  
  it 'will correctly find something split on @' do
    special_cases.search('name:KGNoise').should == ["KGNoise", "KGNoise@tonyzonghui"]
    special_cases.search('name:KGNoise@tonyzonghui').should == ['KGNoise@tonyzonghui']
  end
  
  it 'will correctly find something split on -' do
    special_cases.search('name:kyoto').should == ['kyoto-cabinet']
    special_cases.search('name:cabinet').should == ['kyoto-cabinet']
    special_cases.search('name:kyoto-cabinet').should == ['kyoto-cabinet']
    special_cases.search('name:kyoto name:cabinet').should == ['kyoto-cabinet']
  end
  
  it 'will correctly find something split on -' do
    special_cases.search('name:mkmapview"').should == ['MKMapView+AttributionView']
    special_cases.search('name:AttributionView"').should == ['MKMapView+AttributionView']
    special_cases.search('name:mkmapview name:attributionview').should == ['MKMapView+AttributionView']
  end

end
