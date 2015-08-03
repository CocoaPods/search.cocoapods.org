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
    
  end
end
