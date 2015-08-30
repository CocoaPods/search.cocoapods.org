# coding: utf-8
#
require File.expand_path('../../spec_helper', __FILE__)

describe 'Indexing Progress Tests' do
  
  # The Search#count method works.
  ok { Search.instance.count.should == 200 }

end
