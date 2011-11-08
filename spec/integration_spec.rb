# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

# TODO Use a fixed set of pods.
#
describe 'Integration Tests' do

  before(:all) do
    Picky::Indexes.index_for_tests
    Picky::Indexes.reload
  end

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/search/full') }

  # Testing a count of results.
  #
  it { pods.search('1.0.0').total.should == 2 }

  # Testing a specific order of result ids.
  #
  it { pods.search('1.0.0 k').ids.should == [] }

  # Testing an order of result categories.
  #
  it { pods.search('k* a').should have_categories(['name', 'author']) }
  it { pods.search('jsonkit').should have_categories(['name'], ['dependencies']) }

end