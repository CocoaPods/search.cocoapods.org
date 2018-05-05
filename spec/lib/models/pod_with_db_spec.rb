# frozen_string_literal: true
require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../lib/models/pod', __FILE__)

describe Pod do

  describe 'AFNetworking' do

    def pod
      SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
    end

    ok { pod.name.should == 'AFNetworking' }
    ok { pod.mapped_name.should == 'afnetworking af networking' }
    ok { pod.split_name.should == %w(afnetworking af networking) }
    ok { pod.split_name_for_automatic_splitting.should == ['networking'] }

    ok { pod.authors.should == { :'Mattt Thompson' => 'm@mattt.me' } }
    ok { pod.mapped_authors.should == 'Mattt Thompson' }

    ok { pod.platforms.should == [:ios, :osx, :watchos, :tvos] }
    ok { pod.mapped_platform.should == 'ios osx watchos tvos' }

    ok { pod.dependencies.should == [] }
    
    ok { pod.tags.should == [:network] }

    ok { pod.mapped_dependencies.should == %(Security SystemConfiguration) }
    ok { pod.frameworks.should == %w(Security SystemConfiguration) }

    ok { pod.mapped_subspec_names.should == %(Serialization Security Reachability NSURLSession UIKit) }

    ok { pod.summary.should == 'A delightful iOS and OS X networking framework.' }

    ok { pod.cocoadocs?.should == true }

    # This is just a rough sanity check.
    ok { pod.popularity.should >= 70_000 }
    ok { pod.forks.should >= 3400 }
    ok { pod.contributors.should >= 30 }
    ok { pod.subscribers.should >= 1000 }

    ok {
      pod.to_h.should == {
        id: "AFNetworking",
        platforms: [:ios, :osx, :watchos, :tvos],
        version: :"3.1.0",
        summary: "A delightful iOS and OS X networking framework.",
        authors: {
          :"Mattt Thompson" => :"m@mattt.me"
        },
        link: "https://github.com/AFNetworking/AFNetworking",
        source: {
          git: "https://github.com/AFNetworking/AFNetworking.git",
          tag: "3.1.0",
          submodules: true
        },
        tags: [:network],
        cocoadocs: true
        # If they are not true, they are not added.
        # deprecated: false,
        # deprecated_in_favor_of: nil
      }
    }
  end

  describe 'KGDiscreetAlertView' do

    def pod
      SearchPod.all { |pods| pods.where(name: 'KGDiscreetAlertView') }.first
    end

    ok { pod.platforms.should == [:ios] }
    ok { pod.mapped_platform.should == 'ios' }

  end

  describe 'CCLDefaults' do

    def pod
      SearchPod.all { |pods| pods.where(name: 'CCLDefaults') }.first
    end

    ok { pod.mapped_authors.should == 'Kyle Fuller' }

  end

  describe 'QueryKit' do

    def pod
      SearchPod.all { |pods| pods.where(name: 'QueryKit') }.first
    end

    ok { pod.mapped_authors.should == 'Kyle Fuller' }

  end
  
  describe 'synthetic case #1' do
    
    def pod
      af = SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
      class << af
        def source
          { http: 'http://parse-ios.s3.amazonaws.com/d9dd1242464f5bb586d9f8d660045c04/parse-library-1.6.2.zip' }
        end
      end
      af
    end
    
    ok do
      pod.to_h[:source].should == { http: "http://parse-ios.s3.amazonaws.com/d9dd1242464f5bb586d9f8d660045c04/parse-library-1.6.2.zip" }
    end
    
  end
  
  describe 'synthetic case #2' do
    
    def pod
      af = SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
      class << af
        def source
          { git: "https://github.com/tibo/BlockRSSParser.git" }
        end
      end
      af
    end
    
    ok do
      pod.to_h[:source].should == { git: "https://github.com/tibo/BlockRSSParser.git" }
    end
    
  end
  
  describe 'synthetic case #3' do
    
    def pod
      af = SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
      class << af
        def source
          { git: "git://github.com/OliverLetterer/GHMarkdownParser.git" }
        end
      end
      af
    end
    
    ok do
      pod.to_h[:source].should == { git: "git://github.com/OliverLetterer/GHMarkdownParser.git" }
    end
    
  end
  
  describe 'synthetic case #4' do
    
    def pod
      af = SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
      class << af
        def source
          { http: "http://sourceforge.net/projects/uriparser/files/Sources/0.7.7/uriparser-0.7.7.zip" }
        end
      end
      af
    end
    
    ok do
      pod.to_h[:source].should == { http: "http://sourceforge.net/projects/uriparser/files/Sources/0.7.7/uriparser-0.7.7.zip" }
    end
    
  end
  
  describe 'synthetic case #5' do
    
    def pod
      af = SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
      class << af
        def source
          { http: "http://sourceforge.net/projects/uriparser/files/Sources/0.7.7/uriparser-0.7.7.zip" }
        end
      end
      af
    end
    
    ok do
      pod.to_h[:source].should == { http: "http://sourceforge.net/projects/uriparser/files/Sources/0.7.7/uriparser-0.7.7.zip" }
    end
    
  end
  
  describe 'synthetic case #5' do
    
    def pod
      af = SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
      class << af
        def source
          nil
        end
      end
      af
    end
    
    ok do
      pod.to_h[:source].should == nil
    end
    
  end
  
  describe 'synthetic case #6' do
      
    def pod
      af = SearchPod.all { |pods| pods.where(name: 'AFNetworking') }.first
      class << af
        def homepage
          'https://www.github.com/venmo/VENTouchLock'
        end
      end
      af
    end
    
    ok do
      pod.to_h[:link].should == 'https://github.com/venmo/VENTouchLock'
    end
  end
end
