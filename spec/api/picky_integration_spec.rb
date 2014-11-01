# coding: utf-8
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the Picky style API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do
    
  def pod_ids
    @pod_ids ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.picky.ids.json'
  end
  
  # Testing the format.
  #
  ok { pod_ids.search('on:osx abmultito').entries.should == ['ABMultiton'] }
  
  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, :path => '/api/v1/pods.picky.hash.json'
  end

  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0').total.should == 1131 }
  
  # Testing the format.
  #
  ok { pods.search('on:osx kiwi', sort: 'name').entries.should == [{:id=>"Kiwi", :platforms=>["ios", "osx"], :version=>"2.2.4", :summary=>"A Behavior Driven Development library for iOS and OS X.", :authors=>{:"Allen Ding"=>"alding@gmail.com", :"Luke Redpath"=>"luke@lukeredpath.co.uk", :"Marin Usalj"=>"mneorr@gmail.com", :"Stepan Hruda"=>"stepan.hruda@gmail.com"}, :link=>"https://github.com/allending/Kiwi", :source=>{:git=>"https://github.com/allending/Kiwi.git", :tag=>"2.2.4"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"MSSpec", :platforms=>["ios", "osx"], :version=>"0.1.2", :summary=>"Kiwi Spec with support to inject mocks using Objection", :authors=>{:NachoSoto=>"hello@nachosoto.com"}, :link=>"https://github.com/mindsnacks/MSSpec", :source=>{:git=>"https://github.com/mindsnacks/MSSpec.git", :tag=>"0.1.2"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}] }
  
  ok { pods.search('on:ios adjust').entries.should == [{:id=>"Adjust", :platforms=>["ios"], :version=>"3.3.3", :summary=>"This is the iOS SDK of Adjust. You can read more about it at http://adjust.io.", :authors=>{:"Christian Wellenbrock"=>"welle@adjust.com"}, :link=>"http://adjust.io", :source=>{:git=>"https://github.com/adeven/adjust_ios_sdk.git", :tag=>"v3.3.3"}, :tags=>["http"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AdjustIO", :platforms=>["ios"], :version=>"2.2.0", :summary=>"This is the iOS SDK of AdjustIo. You can read more about it at http://adjust.io.", :authors=>{:"Christian Wellenbrock"=>"welle@adeven.com"}, :link=>"http://adjust.io", :source=>{:git=>"https://github.com/adeven/adjust_ios_sdk.git", :tag=>"v2.2.0"}, :tags=>["http"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"AdjustIo", :platforms=>["ios"], :version=>"2.0", :summary=>"This is the iOS SDK of AdjustIo. You can read more about it at http://adjust.io.", :authors=>{:"Christian Wellenbrock"=>"welle@adeven.com"}, :link=>"http://adjust.io", :source=>{:git=>"https://github.com/adeven/adjust_ios_sdk.git", :tag=>"v2.0"}, :tags=>["http"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"CXAdjustBlockView", :platforms=>["ios"], :version=>"1.1.0", :summary=>"CXAdjustBlockView(UIScrollView).", :authors=>{:ChrisXu=>"taterctl@gmail.com"}, :link=>"https://github.com/ChrisXu1221/CXAdjustBlockView", :source=>{:git=>"https://github.com/ChrisXu1221/CXAdjustBlockView.git", :tag=>"1.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"ESAdjustableLabel-Category", :platforms=>["ios"], :version=>"0.0.1", :summary=>"This category implements some basic methods to modify the dimensions of a given UILabel.", :authors=>{:"Edgar Schmidt"=>"https://github.com/edgarschmidt"}, :link=>"https://github.com/edgarschmidt/ESAdjustableLabel-Category", :source=>{:git=>"https://github.com/edgarschmidt/ESAdjustableLabel-Category", :commit=>"febfd4d4e3d18f6dfac0637449bdb13a3c89fc04"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"LHSKeyboardAdjusting", :platforms=>["ios"], :version=>"0.0.1", :summary=>"An easy-to-use utility that will automatically resize views whenever a keyboard appears", :authors=>{:"Dan Loewenherz"=>"dan@lionheartsw.com"}, :link=>"http://lionheartsw.com/", :source=>{:git=>"https://github.com/lionheart/LHSKeyboardAdjusting.git", :tag=>"0.0.1"}, :tags=>["view"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"RDHDateAdjustment", :platforms=>["ios", "osx"], :version=>"1.0.0", :summary=>"Categories on NSDate to simplify date adjustment.", :authors=>{:"Rich Hodgkins"=>""}, :link=>"https://github.com/rhodgkins/RDHDateAdjustment", :source=>{:git=>"https://github.com/rhodgkins/RDHDateAdjustment.git", :tag=>"1.0.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"Adjust", :platforms=>["ios"], :version=>"3.3.3", :summary=>"This is the iOS SDK of Adjust. You can read more about it at http://adjust.io.", :authors=>{:"Christian Wellenbrock"=>"welle@adjust.com"}, :link=>"http://adjust.io", :source=>{:git=>"https://github.com/adeven/adjust_ios_sdk.git", :tag=>"v3.3.3"}, :tags=>["http"], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"LumberjackConsole", :platforms=>["ios"], :version=>"2.0.2", :summary=>"On-device CocoaLumberjack console with support for search, adjust levels, copying and more.", :authors=>{:"Ernesto Rivera"=>"rivera.ernesto@gmail.com"}, :link=>"http://ptez.github.io/LumberjackConsole", :source=>{:git=>"https://github.com/PTEz/LumberjackConsole.git", :tag=>"2.0.2"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"Tweaks", :platforms=>["ios"], :version=>"1.1.0", :summary=>"Easily adjust parameters for iOS apps in development.", :authors=>{:"Grant Paul"=>"tweaks@grantpaul.com", :"Kimon Tsinteris"=>"kimon@mac.com"}, :link=>"https://github.com/facebook/Tweaks", :source=>{:git=>"https://github.com/facebook/Tweaks.git", :tag=>"1.1.0"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}] }
  
  ok { pods.search('on:ios RMStepsController', sort: 'name').entries.should == [{:id=>"RMStepsController", :platforms=>["ios"], :version=>"1.0.1", :summary=>"This is an iOS control for guiding users through a process step-by-step", :authors=>{:CooperRS=>"rm@cooperrs.de"}, :link=>"https://github.com/CooperRS/RMStepsController", :source=>{:git=>"https://github.com/CooperRS/RMStepsController.git", :tag=>"1.0.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}, {:id=>"QULQuestionnaire", :platforms=>["ios"], :version=>"0.1", :summary=>"Drop-in in-app questionnaire for iOS", :authors=>{:"Tilo Westermann"=>"tilo.westermann@tu-berlin.de"}, :link=>"https://github.com/QULab/QULQuestionnaire-iOS", :source=>{:git=>"https://github.com/QULab/QULQuestionnaire-iOS.git", :tag=>"0.1"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}] }

  # Testing a specific order of result ids.
  #
  ok { pods.search('on:osx ki', sort: 'name').ids.should == [1282, 819, 3836, 2158, 372, 3829, 30, 554, 3783, 5107, 4939, 3753, 614, 4552, 3113, 4940, 2108, 3404, 2908, 2322]
    # ["ADNKit", "AFKissXMLRequestOperation", "AFKissXMLRequestOperation@aceontech", "AFKissXMLRequestOperation@tonyzonghui", "AZAppearanceKit", "AppKitActor"]
  }
  
  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx a* a', sort: 'name') }.should < 0.01 # seconds
  end

  # Similarity on author.
  #
  ok { pods.search('on:ios allan~', sort: 'name').ids.should == [3163, 267, 2520, 1105, 2554, 2756, 5391, 13, 4847]
    # was ["AQGridView", "AFS3Client"]
  }
  
  # Partial version search.
  #
  ok { pods.search('on:osx abmultiton 2').ids.should == [1285] } # ['ABMultiton'] }
  ok { pods.search('on:osx abmultiton 2.').ids.should == [1285] } # ['ABMultiton'] }
  ok { pods.search('on:osx abmultiton 2.0').ids.should == [1285] } # ['ABMultiton'] }
  ok { pods.search('on:osx abmultiton 2.0.').ids.should == [1285] } # ['ABMultiton'] }
  ok { pods.search('on:osx abmultiton 2.0.5').ids.should == [1285] } # ['ABMultiton'] }
  
  # Platform constrained search (platforms are AND-ed).
  #
  ok { pods.search('on:osx abmultiton', sort: 'name').ids.should == [1285, 1940] } # ["ABMultiton"] }
  ok { pods.search('on:ios abmultiton', sort: 'name').ids.should == [1285, 1940] } # ["ABMultiton"] }
  ok { pods.search('on:osx on:ios abmultiton', sort: 'name').ids.should == [1285, 1940] } # ["ABMultiton"] }
  
  # Category boosting.
  #
  ok { categories_of(pods.search('on:osx k* a')).should == [["platform", "name"], ["platform", "author"]] }
  ok { categories_of(pods.search('on:osx abmultiton')).should == [["platform", "name"], ["platform", "dependencies"]] }
  
  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx').total.should == 834 }
  ok { pods.search('platform:os').total.should == 0 }
  ok { pods.search('platform:o').total.should == 0 }
  
  # Rendering.
  #
  pod_spec = "pod 'Kiwi', '~&gt; 1.0.0'"
  ok { pods.search('kiwi allen ding').entries.should == [{:id=>"Kiwi", :platforms=>["ios", "osx"], :version=>"2.2.4", :summary=>"A Behavior Driven Development library for iOS and OS X.", :authors=>{:"Allen Ding"=>"alding@gmail.com", :"Luke Redpath"=>"luke@lukeredpath.co.uk", :"Marin Usalj"=>"mneorr@gmail.com", :"Stepan Hruda"=>"stepan.hruda@gmail.com"}, :link=>"https://github.com/allending/Kiwi", :source=>{:git=>"https://github.com/allending/Kiwi.git", :tag=>"2.2.4"}, :tags=>[], :deprecated=>false, :deprecated_in_favor_of=>nil}] }
  
  # Qualifiers.
  #
  ok { pods.search('name:abmultiton').ids.should == [1285] } # ["ABMultiton"] }
  ok { pods.search('pod:abmultiton').ids.should == [1285] } # ["ABMultiton"] }
  
  ok { pods.search('author:allen author:jared').ids.should == [5391] } # ['AFS3Client'] }
  ok { pods.search('authors:allen authors:jared').ids.should == [5391] } # ['AFS3Client'] }
  ok { pods.search('written:allen written:jared').ids.should == [5391] } # ['AFS3Client'] }
  ok { pods.search('writer:allen writer:jared').ids.should == [5391] } # ['AFS3Client'] }
  # ok { pods.search('by:allen by:jared').ids.should == [5391] } # ['AFS3Client'] }
  
  ok { pods.search('version:1.0.0', sort: 'name').ids.should == [3193, 1191, 356, 1285, 4482, 5419, 3401, 1618, 946, 1769, 4818, 2018, 4794, 2302, 5319, 1168, 2407, 745, 5318, 3356] } # ["AAShareBubbles", "ABCalendarPicker", "ABGetMe", "ABMultiton", "ABStaticTableViewController", "ACColorKit", "ACDCryptsyAPI", "ACEAutocompleteBar", "ACEDrawingView", "ACEExpandableTextCell", "ACETelPrompt", "ACPButton", "ACPReminder", "ACPScrollMenu", "ADBActors", "ADBBackgroundCells", "ADBDownloadManager", "ADBIndexedTableView", "ADBReasonableTextView", "ADCExtensions"] }
  
  expected_dependencies = [3322, 1209, 2335, 394, 1949, 2276, 193, 219, 2370, 854, 696, 1361, 2506, 1281, 1826, 643]
  
  ok { pods.search('dependency:JSONKit', sort: 'name').ids.should == expected_dependencies }
  ok { pods.search('dependencies:JSONKit', sort: 'name').ids.should == expected_dependencies }
  ok { pods.search('depends:JSONKit', sort: 'name').ids.should == expected_dependencies }
  ok { pods.search('using:JSONKit', sort: 'name').ids.should == expected_dependencies }
  ok { pods.search('uses:JSONKit', sort: 'name').ids.should == expected_dependencies }
  ok { pods.search('use:JSONKit', sort: 'name').ids.should == expected_dependencies }
  ok { pods.search('needs:JSONKit', sort: 'name').ids.should == expected_dependencies }
  
  ok { pods.search('platform:osx').total.should == 834 }
  ok { pods.search('on:osx').total.should == 834 }
  
  ok { pods.search('summary:google', sort: 'name').ids.should == [1542, 203, 1435, 1434, 3228, 664, 3465, 3557, 4465, 3979, 2601, 1296, 2744, 1160, 551, 812, 5444, 2883, 2439, 4600] } # ["LARSAdController", "MTLocation", "MTStatusBarOverlay"] }
  
  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').ids.should == [] }

end
