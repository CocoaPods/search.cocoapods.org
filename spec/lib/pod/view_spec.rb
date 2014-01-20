# coding: utf-8
#
require File.expand_path '../../../spec_helper', __FILE__

describe Pod::View do
  
  describe 'simple example' do

    def view
      @view ||= Pod::View.new 'id', 'platforms', 'version', 'summary', 'authors', 'link', 'source', 'subspecs', 'tags', nil
    end
    
    describe '#to_hash' do
      
      it 'is correct' do
        view.to_hash.should == {:id=>"id", :platforms=>"platforms", :version=>"version", :summary=>"summary", :authors=>"authors", :link=>"link", :source=>"source", :subspecs=>"subspecs", :tags=>"tags"}
      end
      
      it 'is ok with documentation_url' do
        view.documentation_url = 'documentation_url'
        view.to_hash.should == {:id=>"id", :platforms=>"platforms", :version=>"version", :summary=>"summary", :authors=>"authors", :link=>"link", :source=>"source", :subspecs=>"subspecs", :tags=>"tags", :documentation_url=>"documentation_url"}
      end
      
    end

  end
  
end