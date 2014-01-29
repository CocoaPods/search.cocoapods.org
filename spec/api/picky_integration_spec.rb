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
  ok { pods.search('on:ios 1.0.0').total.should == 66 }

  # Testing a specific order of result ids.
  #
  ok { pods.search('on:osx ki').ids.should == ["JSONKit", "KISSmetrics", "KissXML", "Kiwi", "MKNetworkKit", "MacMapKit", "KISSmetrics", "KLExpandingSelect", "LibYAML", "MTDates", "MTGeometry", "MTJSONDictionary", "MTJSONUtils", "MTPocket", "MTQueue", "MTStringAttributes", "KISSmetrics", "LastFm", "MKFoundation"] }
  
  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.005 # seconds
  end

  # Similarity on author.
  #
  ok { pods.search('on:ios allan~').ids.should == ["Kiwi"] }
  
  # Partial version search.
  #
  ok { pods.search('on:osx kiwi 1').ids.should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.').ids.should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.0').ids.should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.0.').ids.should == ['Kiwi'] }
  ok { pods.search('on:osx kiwi 1.0.0').ids.should == ['Kiwi'] }
  
  # Platform constrained search (platforms are AND-ed).
  #
  ok { pods.search('on:osx allen').ids.should == ["Kiwi"] }
  ok { pods.search('on:ios allen').ids.should == ["Kiwi"] }
  ok { pods.search('on:osx on:ios allen').ids.should == ["Kiwi"] }
  
  # Category boosting.
  #
  ok { categories_of(pods.search('on:osx k* a')).should == [["platform", "name"], ["platform", "author"], ["platform", "summary"], ["platform", "dependencies"]] }
  ok { categories_of(pods.search('on:osx jsonkit')).should == [["platform", "name"]] }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx').total.should == 108 }
  ok { pods.search('platform:os').total.should == 0 }
  ok { pods.search('platform:o').total.should == 0 }
  
  # Rendering.
  #
  pod_spec = "pod 'Kiwi', '~&gt; 1.0.0'"
  ok {
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
  ok { pods.search('name:kiwi').ids.should == ["Kiwi"] }
  ok { pods.search('pod:kiwi').ids.should == ["Kiwi"] }
  
  ok { pods.search('author:allen').ids.should == ['Kiwi'] }
  ok { pods.search('authors:allen').ids.should == ['Kiwi'] }
  ok { pods.search('written:allen').ids.should == ['Kiwi'] }
  ok { pods.search('writer:allen').ids.should == ['Kiwi'] }
  ok { pods.search('by:allen').ids.should == ['Kiwi'] }
  
  ok { pods.search('version:1.0.0').ids.should == ["JASidePanels", "JCDHTTPConnection", "JCNotificationBannerPresenter", "JDDroppableView", "JDFlipNumberView", "JGAFImageCache", "JJCachedAsyncViewDrawing", "JTTargetActionBlock", "JWT", "JXHTTP", "KGNoise", "KISSmetrics", "KJSimpleBinding", "KTOneFingerRotationGestureRecognizer", "KYArcTab", "KYCircleMenu", "Kiwi", "KoaPullToRefresh", "LARSBar", "LARSTorch"] }
  
  expected_dependencies = ["KeenClient"]
  
  ok { pods.search('dependency:JSONKit').ids.should == expected_dependencies }
  ok { pods.search('dependencies:JSONKit').ids.should == expected_dependencies }
  ok { pods.search('depends:JSONKit').ids.should == expected_dependencies }
  ok { pods.search('using:JSONKit').ids.should == expected_dependencies }
  ok { pods.search('uses:JSONKit').ids.should == expected_dependencies }
  ok { pods.search('use:JSONKit').ids.should == expected_dependencies }
  ok { pods.search('needs:JSONKit').ids.should == expected_dependencies }
  
  ok { pods.search('platform:osx').total.should == 108 }
  ok { pods.search('on:osx').total.should == 108 }
  
  ok { pods.search('summary:google').ids.should == ["LARSAdController", "MTLocation", "MTStatusBarOverlay"] }
  
  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').ids.should == [] }

end
