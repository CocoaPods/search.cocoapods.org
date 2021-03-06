# coding: utf-8
# frozen_string_literal: true
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the Picky style API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do

  def pod_ids
    @pod_ids ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.picky.ids.json'
  end

  def first_three_names_for_search(query, options = {})
    pods.search(query, options).entries.map { |entry| entry[:id] }.first(3)
  end

  # Testing the format.
  #
  ok { pod_ids.search('on:osx afnetwork').entries.first.should == 'AFNetworking' }

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.picky.hash.json'
  end

  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0').total.should == 63 }

  # Testing the format.
  #
  # Not symbolized as it is parsed JSON.
  ok { pods.search('on:osx afnetworking', sort: 'name').entries.first.should == {:id=>"AFNetworking", :platforms=>["ios", "osx", "watchos", "tvos"], :version=>"3.1.0", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"3.1.0", :submodules=>true}, :tags=>["network"], :cocoadocs=>true} }

  # Testing a specific order of result ids.
  #
  ok do
    first_three_names_for_search('on:osx ki', sort: 'name').should == %w(BlocksKit FormatterKit IGListKit)
  end

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx a* a', sort: 'name') }.should < 0.01 # seconds
  end

  # Similarity on author.
  #
  # Has been removed.
  # ok do
  #   first_three_names_for_search('on:ios mettt~', sort: 'name').should == %w(AFIncrementalStore AFNetworking CargoBay)
  # end

  # Partial version search.
  #
  expected = %w(AFNetworking YTKNetwork YTKNetwork)
  ok { first_three_names_for_search('on:osx afnetworking 2', sort: 'name').should == expected }
  ok { first_three_names_for_search('on:osx afnetworking 2.', sort: 'name').should == expected }
  ok { first_three_names_for_search('on:osx afnetworking 2.0', sort: 'name').should == expected }
  ok { first_three_names_for_search('on:osx afnetworking 2.0.', sort: 'name').should == expected }
  ok { first_three_names_for_search('on:osx afnetworking 2.0.0', sort: 'name').should == expected }

  # Platform constrained search (platforms are AND-ed).
  #
  expected = %w(AFNetworking YTKNetwork YTKNetwork)
  ok { first_three_names_for_search('on:osx afnetworking', sort: 'name').should == expected }
  ok { first_three_names_for_search('on:osx on:ios afnetworking', sort: 'name').should == expected }
  ok { first_three_names_for_search('on:ios afnetworking', sort: 'name').should == %w(AFNetworking YTKNetwork Nimbus) }

  # Category boosting.
  #
  # ok { categories_of(pods.search('on:ios s* a*')).should == [%w(platform name), %w(platform author)] }
  # ok { categories_of(pods.search('on:ios a*')).should == [%w(platform name), %w(platform dependencies)] }

  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx').total.should == 87 }
  ok { pods.search('platform:os').total.should == 0 }
  ok { pods.search('platform:o').total.should == 0 }

  # Rendering.
  #
  ok { pods.search('afnetworking mattt thompson', sort: 'name').entries.first.should == { :id=>"AFNetworking", :platforms=>["ios", "osx", "watchos", "tvos"], :version=>"3.1.0", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"3.1.0", :submodules=>true}, :tags=>["network"], :cocoadocs=>true} }

  # Qualifiers.
  #
  expected = ['AFNetworking']
  ok { first_three_names_for_search('name:afnetworking').should == expected }
  ok { first_three_names_for_search('pod:afnetworking').should == expected }

  expected = %w(AFNetworking FormatterKit TTTAttributedLabel)
  ok { first_three_names_for_search('author:mattt author:thompson', sort: 'name').should == expected }
  ok { first_three_names_for_search('authors:mattt authors:thompson', sort: 'name').should == expected }
  ok { first_three_names_for_search('written:mattt written:thompson', sort: 'name').should == expected }
  ok { first_three_names_for_search('writer:mattt writer:thompson', sort: 'name').should == expected }
  # ok { first_three_names_for_search('writer:mattt writer:thompson').should == expected }

  ok { first_three_names_for_search('version:1.0.0', sort: 'name').should == %w(Appirater Aspects Atlas) }

  expected_dependencies = %w(Nimbus YTKNetwork)
  ok { first_three_names_for_search('dependency:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('dependencies:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('depends:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('using:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('uses:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('use:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('needs:AFNetworking', sort: 'name').should == expected_dependencies }

  ok { pods.search('platform:osx').total.should == 87 }
  ok { pods.search('on:osx').total.should == 87 }

  ok { first_three_names_for_search('summary:data', sort: 'name').should == %w(IGListKit JSONModel MagicalRecord) }

  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').ids.should == [] }

  it 'will find a podspec searched by a full subspec name' do
    first_three_names_for_search('RestKit/CoreData', sort: 'name').should == %w(RestKit RestKit RestKit)
    first_three_names_for_search('AFNetworking/NSURLSession', sort: 'name').should == %w(AFNetworking)
  end

end
