require File.expand_path('../../../spec_helper_without_db', __FILE__)
require File.expand_path('../../../../lib/models/pod', __FILE__)

describe Pod do

  describe 'Synthetic cases' do
    
    describe 'deprecated_in_favor_of set' do
      def pod
        af = Pod.new({})
        class << af
          def specification
            {
              deprecated: false,
              deprecated_in_favor_of: 'SomethingElse'
            }
          end
        end
        af
      end
    
      ok do
        pod.deprecated?.should == true
      end
    end
    
    describe 'deprecated_in_favor_of not set' do
      def pod
        af = Pod.new({})
        class << af
          def specification
            {
              deprecated: false
            }
          end
        end
        af
      end
    
      ok do
        pod.deprecated?.should == false
      end
    end
    
    describe '#split_name' do
      def pod
        @pod ||= Pod.new({})
      end

      def ok_split pod_name, *expected
        pod.singleton_class.send(:define_method, :name) do
          pod_name
        end
        should "split #{pod_name} into #{expected}" do
          pod.split_name.should == expected
        end
      end

      ok_split 'NMSSH', 'nmssh', 'nm', 'ssh'
      ok_split 'WJHXCTest', 'wjhxctest', 'wjhxc', 'test'
      ok_split 'SSHTTPClient', 'sshttpclient', 'sshttp', 'client'
      ok_split 'AFNetworking', 'afnetworking', 'af', 'networking'
      ok_split 'CCLDefaults', 'ccldefaults', 'ccl', 'defaults'
      # Dirty characters will be removed in the indexing step.
      ok_split 'isUnitTesting', 'isunittesting', 'is', 'unittesting', '', 'unit', 'testing'
      ok_split 'JSON-Schema-Test-Suite', 'json-schema-test-suite', 'js', 'on', 'json', "-", 'schema', 'test', 'suite', 'json-'
    end
    
  end
end
