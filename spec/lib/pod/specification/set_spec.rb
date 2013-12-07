# coding: utf-8
#
require 'spec_helper'

describe Pod::Specification::Set do
  
  context 'simple example' do

    let(:set) { described_class.new 'ABCSomeName' }
  
    it '' do
      set.split_name.should == ["ABCSomeName", "abc", "some", "", "name", "somename"]
    end

  end
  
end