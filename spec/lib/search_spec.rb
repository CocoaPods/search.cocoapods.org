# frozen_string_literal: true
require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/search', __FILE__)

describe Search do

  def specification
    @specification ||= Hashie::Mash.new(
      'id' => 99999999999999999,
      'name' => 'AFNetworking',
      'version' => '2.3.1',
      'license' => 'MIT',
      'summary' => 'A delightful iOS and OS X networking framework.',
      'homepage' => 'https://github.com/AFNetworking/AFNetworking',
      'social_media_url' => 'https://twitter.com/AFNetworking',
      'authors' => { 'Mattt Thompson' => 'm@mattt.me' },
      'source' => {
        'git' => 'https://github.com/AFNetworking/AFNetworking.git',
        'tag' => '2.3.1',
        'submodules' => true },
      'requires_arc' => true,
      'platforms' => {
        'ios' => '6.0',
        'osx' => '10.8',
      },
      'public_header_files' => 'AFNetworking/*.h',
      'source_files' => 'AFNetworking/AFNetworking.h',
      'subspecs' => [
        {
          'name' => 'Serialization',
          'source_files' => 'AFNetworking/AFURL{Request,Response}Serialization.{h,m}',
          'ios' => {
            'frameworks' => %w(MobileCoreServices CoreGraphics),
          },
          'osx' => {
            'frameworks' => 'CoreServices',
          },
        },
        {
          'name' => 'Security',
          'source_files' => 'AFNetworking/AFSecurityPolicy.{h,m}',
          'frameworks' => 'Security',
        }, {
          'name' => 'Reachability',
          'source_files' => 'AFNetworking/AFNetworkReachabilityManager.{h,m}',
          'frameworks' => 'SystemConfiguration',
        },
        {
          'name' => 'NSURLConnection',
          'dependencies' => {
            'AFNetworking/Serialization' => [],
            'AFNetworking/Reachability' => [],
            'AFNetworking/Security' => [],
          },
          'source_files' => [
            'AFNetworking/AFURLConnectionOperation.{h,m}',
            'AFNetworking/AFHTTPRequestOperation.{h,m}',
            'AFNetworking/AFHTTPRequestOperationManager.{h,m}',
          ],
        },
        {
          'name' => 'NSURLSession',
          'dependencies' => {
            'AFNetworking/Serialization' => [],
            'AFNetworking/Reachability' => [],
            'AFNetworking/Security' => [],
          },
          'source_files' => [
            'AFNetworking/AFURLSessionManager.{h,m}',
            'AFNetworking/AFHTTPSessionManager.{h,m}',
          ],
        },
        {
          'name' => 'UIKit',
          'platforms' => {
            'ios' => '6.0',
          },
          'dependencies' => {
            'AFNetworking/NSURLConnection' => [],
            'AFNetworking/NSURLSession' => [],
          },
          'ios' => {
            'public_header_files' => 'UIKit+AFNetworking/*.h',
            'source_files' => 'UIKit+AFNetworking',
          },
          'osx' => {
            'source_files' => '',
          },
        }
      ],
      )
  end

  describe 'replace' do

    it 'also updates the cache' do
      pods = Pods.new
      search = Search.new

      old_pod = SearchPod.new(specification)

      pods[old_pod.id].should.nil?

      new_pod = SearchPod.new(specification)

      search.replace(new_pod, pods) rescue nil

      pods[new_pod.id].should == new_pod
    end

  end

end
