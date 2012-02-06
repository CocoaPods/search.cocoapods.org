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
    CocoapodSearch.prepare # Needed to load the data for the rendered search results.
  end

  let(:pods) { Picky::TestClient.new(CocoapodSearch, :path => '/search') }
  
  # Testing a count of results.
  #
  it { pods.search('on:ios 1.0.0').total.should == 2 }

  # Testing a specific order of result ids.
  #
  it { pods.search('on:osx k').ids.should == ['Kiwi', 'SSKeychain'] }
  
  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.0025 # seconds
  end

  # Similarity on author.
  #
  it { pods.search('on:ios thompsen~').ids.should == ['FormatterKit', 'TTTAttributedLabel'] }
  
  # Partial version search.
  #
  it { pods.search('on:osx kiwi 1').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0.').ids.should == ['Kiwi'] }
  it { pods.search('on:osx kiwi 1.0.0').ids.should == ['Kiwi'] }
  
  # Platform constrained search (platforms are AND-ed).
  #
  it { pods.search('on:osx thompson').ids.should == ['FormatterKit'] }
  it { pods.search('on:ios thompson').ids.should == ['FormatterKit', 'TTTAttributedLabel'] }
  it { pods.search('on:osx on:ios thompson').ids.should == ['FormatterKit'] }
  
  # Category boosting.
  #
  it { pods.search('on:osx k* a').should have_categories(['platform', 'name', 'author'], ['platform', 'name', 'summary']) }
  it { pods.search('on:osx jsonkit').should have_categories(['platform', 'name'], ['platform', 'dependencies']) }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  it { pods.search('platform:osx').total.should == 24 }
  it { pods.search('platform:os').total.should == 0 }
  it { pods.search('platform:o').total.should == 0 }
  
  # Rendering.
  #
  it { pods.search('kiwi').entries.should == ['<div class="pod"><h3 class="name"><a href="http://kiwi-lib.info">Kiwi</a></h3><div class="version">1.0.0</div><div class="summary"><p>A Behavior Driven Development library  iPhone  iPad development.</p></div><div class="authors"><a href="javascript:pickyClient.insert(\'Allen Ding\')">Allen Ding</a> and <a href="javascript:pickyClient.insert(\'Luke Redpath\')">Luke Redpath</a></div></div><hr>'] }
  
  # Qualifiers.
  #
  it { pods.search('name:kiwi').ids.should == ['Kiwi'] }
  it { pods.search('pod:kiwi').ids.should == ['Kiwi'] }
  
  it { pods.search('author:allen').ids.should == ['Kiwi'] }
  it { pods.search('authors:allen').ids.should == ['Kiwi'] }
  it { pods.search('written:allen').ids.should == ['Kiwi'] }
  it { pods.search('writer:allen').ids.should == ['Kiwi'] }
  it { pods.search('by:allen').ids.should == ['Kiwi'] }
  
  it { pods.search('version:1.0.0').ids.should == ['Kiwi', 'MGSplitViewController'] }
  
  it { pods.search('dependency:JSONKit').ids.should == ['AFNetworking', 'RestKit-JSON-JSONKit'] }
  it { pods.search('dependencies:JSONKit').ids.should == ['AFNetworking', 'RestKit-JSON-JSONKit'] }
  it { pods.search('depends:JSONKit').ids.should == ['AFNetworking', 'RestKit-JSON-JSONKit'] }
  it { pods.search('using:JSONKit').ids.should == ['AFNetworking', 'RestKit-JSON-JSONKit'] }
  it { pods.search('uses:JSONKit').ids.should == ['AFNetworking', 'RestKit-JSON-JSONKit'] }
  it { pods.search('use:JSONKit').ids.should == ['AFNetworking', 'RestKit-JSON-JSONKit'] }
  it { pods.search('needs:JSONKit').ids.should == ['AFNetworking', 'RestKit-JSON-JSONKit'] }
  
  it { pods.search('platform:osx').total.should == 24 }
  it { pods.search('on:osx').total.should == 24 }
  
  it { pods.search('summary:google').ids.should == ['MTLocation', 'MTStatusBarOverlay'] }
  
  #
  # TODO We need specs. Lots of specs.
  #

end