# coding: utf-8
#
require File.expand_path('../../spec_helper_without_db', __FILE__)

describe 'Indexing Progress Tests' do

  def search *parameters, indexing_progress
    Search.instance.search(*parameters, indexing_progress).to_hash
  end
  
  ok { search('whatever', 20, 0, { :format => :picky }, 0.12)[:indexing_progress].should == 0.12 }

end
