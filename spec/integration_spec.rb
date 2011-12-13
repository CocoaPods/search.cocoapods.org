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
  end

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/search/full') }

  # Testing a count of results.
  #
  it { pods.search('1.0.0').total.should == 2 }

  # Testing a specific order of result ids.
  #
  it { pods.search('1.0* k').ids.should == ['Kiwi'] }

  # Testing an order of result categories.
  #
  it { pods.search('k* a').should have_categories(['name', 'author'], ["name", "summary"]) }
  it { pods.search('jsonkit').should have_categories(['name'], ['dependencies']) }

  # Similarity on author.
  #
  it { pods.search('thompsen~').ids.should == ['FormatterKit', 'TTTAttributedLabel'] }

  #
  # TODO We need specs. Lots of specs.
  #

end