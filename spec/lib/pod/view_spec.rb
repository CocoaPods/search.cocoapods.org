# coding: utf-8
#
require 'spec_helper'

describe Pod::View do
  
  context 'simple example' do

    let(:view) { described_class.new 'id', 'platforms', 'version', 'summary', 'authors', 'link', 'source', 'subspecs', 'tags', nil }
    
    describe '#to_hash' do
      
      it 'is correct' do
        view.to_hash.should == {:id=>"id", :platforms=>"platforms", :version=>"version", :summary=>"summary", :authors=>"authors", :link=>"link", :source=>"source", :subspecs=>"subspecs", :tags=>"tags"}
      end
      
      it 'is correct with documentation_url' do
        view.documentation_url = 'documentation_url'
        view.to_hash.should == {:id=>"id", :platforms=>"platforms", :version=>"version", :summary=>"summary", :authors=>"authors", :link=>"link", :source=>"source", :subspecs=>"subspecs", :tags=>"tags", :documentation_url=>"documentation_url"}
      end
      
    end

  end
  
end