# coding: utf-8
#
require 'spec_helper'

describe Pod::Specification::WrappedSet do
  
  context 'simple example' do

    let(:set) { described_class.new Pod::Specification::Set.new 'ABCSomeName' }
  
    it 'splits the set name correctly' do
      set.split_name.should == ["ABCSomeName", "abc", "some", "", "name", "somename"]
    end

  end
  
end