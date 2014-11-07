require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../lib/models/pod', __FILE__)

describe Pod do
  describe 'AFNetworking' do
    
    def pod
      Pod.all { |pods| pods.where(name: 'AFNetworking') }.first
    end
  
    ok { pod.name.should == 'AFNetworking' }
    ok { pod.split_name.should == ['afnetworking', 'af', 'networking'] }
    ok { pod.split_name_for_automatic_splitting.should == ['networking'] }
    
  end
end
