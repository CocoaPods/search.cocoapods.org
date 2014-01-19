# coding: utf-8
#
require File.expand_path '../../../../spec_helper', __FILE__

describe Pod::Specification::WrappedSet do
  
  describe 'simple example' do
    
    def set
      @set ||= Pod::Specification::WrappedSet.new Pod::Specification::Set.new 'ABCSomeName'
    end
  
    it 'splits the set name correctly' do
      set.split_name.should == ["ABCSomeName", "abc", "some", "", "name", "somename"]
    end

  end
  
end