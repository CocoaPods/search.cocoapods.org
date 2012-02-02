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

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/search/full') }
  
  # Testing a count of results.
  #
  it { pods.search('on:ios 1.0.0').total.should == 2 }

  # Testing a specific order of result ids.
  #
  it { pods.search('on:osx 1.0* k').ids.should == ['Kiwi'] }

  # Testing an order of result categories.
  #
  it { pods.search('on:osx k* a').should have_categories(['platform', 'name', 'author'], ['platform', 'name', 'summary']) }
  it { pods.search('on:osx jsonkit').should have_categories(['platform', 'name'], ['platform', 'dependencies']) }

  # Similarity on author.
  #
  it { pods.search('on:ios thompsen~').ids.should == ['FormatterKit', 'TTTAttributedLabel'] }

  #
  # TODO We need specs. Lots of specs.
  #

end