# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do
  
  before(:all) do
    Picky::Indexes.index
    Picky::Indexes.load
    CocoapodSearch.prepare # Needed to load the data for the rendered search results.
  end

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/search.json') }
  # Rendering.
  #
  it { pods.search('kiwi 1.0.0').entries.should == ["{\"id\":\"Kiwi\",\"platforms\":[\"osx\",\"ios\"],\"version\":\"2.1\",\"summary\":\"A Behavior Driven Development library for iOS and OS X.\",\"authors\":{\"Allen Ding\":\"alding@gmail.com\",\"Luke Redpath\":\"luke@lukeredpath.co.uk\"},\"link\":\"https://github.com/allending/Kiwi\",\"subspecs\":[],\"tags\":[]}"] }

end
