# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the Picky style API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do
    
  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.picky.hash.json'
  end

  # Testing a count of results.
  #
  correct { pods.search('on:ios 1.0.0').total.should == 66 }

  # Testing a specific order of result ids.
  #
  correct { pods.search('on:osx ki').ids.should == ["JSONKit", "KISSmetrics", "KissXML", "Kiwi", "MKNetworkKit", "MacMapKit", "KISSmetrics", "KLExpandingSelect", "LibYAML", "MTDates", "MTGeometry", "MTJSONDictionary", "MTJSONUtils", "MTPocket", "MTQueue", "MTStringAttributes", "KISSmetrics", "LastFm", "MKFoundation"] }
  
  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.005 # seconds
  end

  # Similarity on author.
  #
  correct { pods.search('on:ios allan~').ids.should == ["Kiwi"] }
  
  # Partial version search.
  #
  correct { pods.search('on:osx kiwi 1').ids.should == ['Kiwi'] }
  correct { pods.search('on:osx kiwi 1.').ids.should == ['Kiwi'] }
  correct { pods.search('on:osx kiwi 1.0').ids.should == ['Kiwi'] }
  correct { pods.search('on:osx kiwi 1.0.').ids.should == ['Kiwi'] }
  correct { pods.search('on:osx kiwi 1.0.0').ids.should == ['Kiwi'] }
  
  # Platform constrained search (platforms are AND-ed).
  #
  correct { pods.search('on:osx allen').ids.should == ["Kiwi"] }
  correct { pods.search('on:ios allen').ids.should == ["Kiwi"] }
  correct { pods.search('on:osx on:ios allen').ids.should == ["Kiwi"] }
  
  # Category boosting.
  #
  correct { categories_of(pods.search('on:osx k* a')).should == [["platform", "name", "name"], ["platform", "name", "author"], ["platform", "author", "summary"], ["platform", "author", "author"], ["platform", "author", "name"], ["platform", "summary", "author"], ["platform", "author", "dependencies"], ["platform", "name", "dependencies"], ["platform", "name", "summary"], ["platform", "summary", "summary"]] }
  correct { categories_of(pods.search('on:osx jsonkit')).should == [["platform", "name"]] }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  correct { pods.search('platform:osx').total.should == 108 }
  correct { pods.search('platform:os').total.should == 0 }
  correct { pods.search('platform:o').total.should == 0 }
  
  # Rendering.
  #
  pod_spec = "pod 'Kiwi', '~&gt; 1.0.0'"
  correct {
    pods.search('kiwi').entries.should == [
      { :id => "Kiwi",
      :platforms => ["osx", "ios"],
      :version => "2.1",
      :summary => "A Behavior Driven Development library for iOS and OS X.",
      :authors =>
       { :"Allen Ding" => "alding@gmail.com",
         :"Luke Redpath" => "luke@lukeredpath.co.uk" },
      :link => "https://github.com/allending/Kiwi",
      :source => { :git => "https://github.com/allending/Kiwi.git", :tag => "2.1" },
      :subspecs => [],
      :tags => [] },
      { :id => "MockInject",
      :platforms => ["ios"],
      :version => "0.1.0",
      :summary =>
        "A library that allows developers to globally mock any ObjectiveC class' initialization method when testing with Kiwi.",
      :authors =>
        { :"Matt Ganski" => "gantasygames@gmail.com" },
      :link => "https://github.com/gantaa/MockInject",
      :source => { :git => "https://github.com/gantaa/MockInject.git", :tag => "0.1.0" },
      :subspecs => [],
      :tags => ["test"]},
      { :id => "MockInject",
      :platforms => ["ios"],
      :version => "0.1.0",
      :summary =>
        "A library that allows developers to globally mock any ObjectiveC class' initialization method when testing with Kiwi.",
      :authors =>
        { :"Matt Ganski" => "gantasygames@gmail.com" },
      :link => "https://github.com/gantaa/MockInject",
      :source => { :git => "https://github.com/gantaa/MockInject.git", :tag => "0.1.0" },
      :subspecs => [],
      :tags => ["test"] }
    ]
  }
  
  # Qualifiers.
  #
  correct { pods.search('name:kiwi').ids.should == ["Kiwi"] }
  correct { pods.search('pod:kiwi').ids.should == ["Kiwi"] }
  
  correct { pods.search('author:allen').ids.should == ['Kiwi'] }
  correct { pods.search('authors:allen').ids.should == ['Kiwi'] }
  correct { pods.search('written:allen').ids.should == ['Kiwi'] }
  correct { pods.search('writer:allen').ids.should == ['Kiwi'] }
  correct { pods.search('by:allen').ids.should == ['Kiwi'] }
  
  correct { pods.search('version:1.0.0').ids.should == ["JASidePanels", "JCDHTTPConnection", "JCNotificationBannerPresenter", "JDDroppableView", "JDFlipNumberView", "JGAFImageCache", "JJCachedAsyncViewDrawing", "JTTargetActionBlock", "JWT", "JXHTTP", "KGNoise", "KISSmetrics", "KJSimpleBinding", "KTOneFingerRotationGestureRecognizer", "KYArcTab", "KYCircleMenu", "Kiwi", "KoaPullToRefresh", "LARSBar", "LARSTorch"] }
  
  expected_dependencies = ["KeenClient"]
  
  correct { pods.search('dependency:JSONKit').ids.should == expected_dependencies }
  correct { pods.search('dependencies:JSONKit').ids.should == expected_dependencies }
  correct { pods.search('depends:JSONKit').ids.should == expected_dependencies }
  correct { pods.search('using:JSONKit').ids.should == expected_dependencies }
  correct { pods.search('uses:JSONKit').ids.should == expected_dependencies }
  correct { pods.search('use:JSONKit').ids.should == expected_dependencies }
  correct { pods.search('needs:JSONKit').ids.should == expected_dependencies }
  
  correct { pods.search('platform:osx').total.should == 108 }
  correct { pods.search('on:osx').total.should == 108 }
  
  correct { pods.search('summary:google').ids.should == ["LARSAdController", "MTLocation", "MTStatusBarOverlay"] }
  
  # No single characters indexed.
  #
  correct { pods.search('on:ios "a"').ids.should == [] }

end
