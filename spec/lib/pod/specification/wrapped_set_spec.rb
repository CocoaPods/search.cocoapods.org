# coding: utf-8
#
require File.expand_path '../../../../spec_helper', __FILE__

describe Pod::Specification::WrappedSet do
  
  describe 'simple example' do
    
    def set
      @set ||= Pod::Specification::WrappedSet.new Pod::Specification::Set.new 'ABCSomeName+OtherName-Abc+Def'
    end
  
    it 'splits the set name correctly' do
      set.split_name.should == ["abcsomename+othername-abc+def", "abc", "somename", "abcsomename", "+", "othername", "-", "def", "some", "", "name", "other"]
    end

  end
  
end